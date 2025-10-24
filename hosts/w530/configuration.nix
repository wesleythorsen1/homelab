{
  pkgs,
  ...
}:

let
  toLua = str: "lua << EOF\n${str}\nEOF\n";

  ipAddress = "100.71.196.98";
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.05";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "wes"
    ];
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  networking = {
    hostName = "w530";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
        6443 # argocd tcp
        10250 # kubelet
        30080 # whoami node-port
        30081 # argocd node-port
      ];
      allowedUDPPorts = [ ];
    };
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  systemd = {
    defaultUnit = "multi-user.target";

    services.fetch-tailscale-key = {
      description = "Fetch Tailscale auth key from Mac (temporary bootstrap)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      requiredBy = [ "tailscaled.service" ];
      before = [ "tailscaled.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "fetch-tailscale-key" ''
          set -euo pipefail
          install -d -m 700 /run/keys
          ${pkgs.curl}/bin/curl -fsS "http://crackbookpro.local/tailscale_key" \
            -o /run/keys/tailscale_key
          chmod 600 /run/keys/tailscale_key
        '';
      };
      wantedBy = [ "multi-user.target" ];
      unitConfig.ConditionPathExists = "!/run/keys/tailscale_key";
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false; # FIXME: not safe
  };

  users.users = {
    root = {
      shell = pkgs.zsh;
    };
    wes = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
        "kvm"
        "libvirtd"
        "networkmanager"
        "systemd-journal"
        "video"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII2Mwvc/ia3Gtu0RQ6WmkoPVI1E+EKAd1akze0SJqA8c wes@crackbookpro"
      ];
    };
  };

  environment = {
    shells = [ pkgs.zsh ];
    loginShellInit = ''
      # Only for interactive shells
      case "$-" in
        *i*) : ;;     # interactive
        *)   return ;; # non-interactive login (e.g., ssh with a command)
      esac

      # Require a real terminal and skip "dumb"
      [ -t 1 ] || return
      [ "${"TERM:-"}" = "dumb" ] && return

      # Run fastfetch if present
      if command -v fastfetch >/dev/null 2>&1; then
        fastfetch
      fi
    '';

    systemPackages = with pkgs; [
      coreutils
      curl
      fastfetch
      git
      jq
      nixos-rebuild # for building NixOS configs
      unzip
      wget
    ];
  };

  services = {
    resolved.enable = true; # systemd-resolved
    acpid.enable = true; # power button/lid signals handled sanely on laptops
    iperf3.enable = true;

    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PubkeyAuthentication = true;
        UseDns = false;
        UsePAM = true;
      };
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      publish.enable = true;
      publish.addresses = true;
      publish.domain = true;
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = "/run/keys/tailscale_key";
      useRoutingFeatures = "server";
      extraUpFlags = [
        "--ssh"
      ];
      extraSetFlags = [
        "--advertise-exit-node"
      ];
    };

    k3s = {
      enable = true;
      role = "server";
      clusterInit = false; # single node (SQLite)
      gracefulNodeShutdown.enable = true;
      extraFlags = [
        "--disable traefik"
        "--disable local-storage"
        "--tls-san"
        ipAddress
        "--tls-san"
        "w530"
        "--write-kubeconfig-mode"
        "0644"
      ];
      autoDeployCharts = {
        argocd = {
          name = "argo-cd";
          repo = "https://argoproj.github.io/argo-helm";
          version = "9.0.3";
          hash = "sha256-0eP8dbsq+iwUSsRC39XcBTHYWcTLNT0AlhiSOl8FSsQ=";
          targetNamespace = "argocd";
          createNamespace = true;
          values.server.service = {
            # TODO: switch to Ingress later
            type = "NodePort";
            nodePortHttp = 30081;
          };
          extraFieldDefinitions = {
            spec.targetNamespace = "argocd";
            spec.createNamespace = true;
          };
        };
      };

      manifests = {
        "argocd-ns".content = {
          apiVersion = "v1";
          kind = "Namespace";
          metadata = {
            name = "argocd";
          };
        };
        "argocd-bootstrap".content = {
          apiVersion = "argoproj.io/v1alpha1";
          kind = "Application";
          metadata = {
            name = "bootstrap";
            namespace = "argocd";
            annotations."argocd.argoproj.io/sync-wave" = "0";
          };
          spec = {
            project = "default";
            source = {
              repoURL = "https://github.com/wesleythorsen1/homelab";
              targetRevision = "main";
              path = "clusters/homelab";
            };
            destination = {
              server = "https://kubernetes.default.svc";
              namespace = "argocd";
            };
            syncPolicy = {
              automated = {
                prune = true;
                selfHeal = true;
              };
              syncOptions = [ "CreateNamespace=true" ];

            };
          };
        };
      };
    };
  };

  programs = {
    git.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    zsh = {
      enable = true;
      enableBashCompletion = true;
      enableCompletion = true;
      enableLsColors = true;
      autosuggestions = {
        enable = true;
        async = true;
      };
      syntaxHighlighting = {
        enable = true;
      };
      interactiveShellInit = ''
        setopt prompt_subst
        . ${../modules/zsh/posh-git.zsh}
        PROMPT='%n@%m %1~$(git_prompt_info) » '
      '';
      shellAliases = {
        c = "clear";
        l = "eza -la";
        lt = "eza -laT -I=.git";
        v = "nvim";
        na = "nixos-rebuild switch --verbose -L --flake "; # . -c dev-shell
      };
      # ohMyZsh = {
      #   enable = true;
      #   theme = "minimal";
      #   # TODO: setup to match home-manager
      #   plugins = [
      #     "git-open"
      #     "deno"
      #   ];
      #   custom = [
      #     "${config.home.homeDirectory}/.oh-my-zsh-custom"
      #   ];
      # };
    };

    bash = {
      enable = true;
      promptInit = ''
        case "$-" in *i*) ;; *) return ;; esac
        . ${../modules/zsh/posh-git.zsh}
        __posh_prompt_prefix="\u@\h \W "
        __posh_prompt_suffix=" » "
        PROMPT_COMMAND='__posh_git_ps1 "$__posh_prompt_prefix" "$__posh_prompt_suffix"'
      '';
    };

    tmux = {
      enable = true;
      keyMode = "vi";
      terminal = "screen-256color";
      shortcut = "Space";
      baseIndex = 1;
      newSession = true;
      escapeTime = 1000;
      extraConfigBeforePlugins = ''
        set -ga terminal-overrides ",*256col*:Tc"
        set -g set-clipboard on
        set -g mouse on
        set -g status-interval 2
        set -g detach-on-destroy off
        set -g renumber-windows on

        # copy-mode-vi tweaks (no mac pbcopy here; rely on OSC52)
        bind -T copy-mode-vi v send -X begin-selection
        bind -T copy-mode-vi y send -X copy-selection-and-cancel
        unbind -T copy-mode-vi MouseDragEnd1Pane
      '';
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      configure = {
        customLuaRC = toLua ''
          vim.g.mapleader = " "
          require("init")
        '';
      };
      runtime = {
        "lua/settings.lua".text = builtins.readFile ../modules/neovim/config/settings.lua;
        "lua/keymaps.lua".text = builtins.readFile ../modules/neovim/config/keymaps.lua;
        "lua/init.lua".text = ''
          require("settings")
          require("keymaps")
        '';
      };
    };
  };

  specialisation.dev-shell.configuration = {
    security.sudo.extraRules = [
      # FIXME: not safe
      {
        users = [ "wes" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    environment = {
      systemPackages = with pkgs; [
        btop
        cmake
        ethtool
        eza
        fd
        lsof
        lua-language-server
        nftables
        nixd
        nmap
        nodejs_24
        nodePackages.typescript
        nodePackages.typescript-language-server
        pciutils
        ripgrep
        rsync
        strace
        usbutils
        zip
      ];
    };

    programs = {
      bat.enable = true;
      iftop.enable = true;
      iotop.enable = true;
      mtr.enable = true;
      nexttrace.enable = true;

      git = {
        enable = true;
        prompt.enable = true;
        config = {
          user = {
            name = "wesleythorsen1";
            email = "wesley.thorsen@gmail.com";
            signingkey = "FAE484F021AE49E5";
          };
          alias = {
            co = "checkout";
            logl = "log --oneline --graph --all";
            pf = "push --force-with-lease";
          };
          core = {
            editor = "nvim";
            repositoryformatversion = 0;
            filemode = true;
            bare = false;
            logallrefupdates = true;
            ignorecase = false;
            precomposeunicode = true;
          };
          credential = {
            # TODO: confirm this works
            helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
            "https://github.com/".useHttpPath = true;
          };
          push = {
            autoSetupRemote = true;
          };
        };
      };

      tmux = {
        enable = true;
        plugins = with pkgs.tmuxPlugins; [
          tmux-powerline
          resurrect
          continuum
        ];
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @continuum-restore 'on'
          set -g status-right '#(${pkgs.gitmux}/bin/gitmux "#{pane_current_path}")'
        '';
      };

      neovim = {
        enable = true;
        configure = {
          packages.myVimPackage = with pkgs.vimPlugins; {
            start = [
              nvim-lspconfig
              nvim-treesitter.withAllGrammars
              telescope-nvim
              telescope-fzf-native-nvim
              nvim-cmp
              cmp-nvim-lsp
              cmp-buffer
              cmp-path
              luasnip
              cmp_luasnip
              vim-fugitive
              undotree
              gitsigns-nvim
              lualine-nvim
              nvim-web-devicons
              snacks-nvim
            ];
            opt = [ ];
          };
        };
        runtime = {
          "lua/treesitter.lua".text = builtins.readFile ../modules/neovim/plugins/treesitter.lua;
          "lua/telescope.lua".text = builtins.readFile ../modules/neovim/plugins/telescope.lua;
          "lua/completion.lua".text = builtins.readFile ../modules/neovim/plugins/completion.lua;
          "lua/lsp.lua".text = builtins.readFile ../modules/neovim/plugins/lsp.lua;
          "lua/snacks.lua".text = builtins.readFile ../modules/neovim/plugins/snacks.lua;
          "lua/init.lua".text = ''
            require("settings")
            require("keymaps")
            require("treesitter")
            require("telescope")
            require("completion")
            require("lsp")
            require("snacks")
            -- Yazi quick-open (uses tmux if present, else terminal)
            vim.keymap.set("n","<leader>yy", function()
              if os.getenv("TMUX") then
                vim.fn.system('tmux split-window -v "yazi"')
              else
                vim.cmd("terminal yazi")
              end
            end, { desc = "Yazi in split/terminal" })
          '';
        };
      };

      yazi = {
        enable = true;
      };

      fzf = {
        fuzzyCompletion = true;
        keybindings = true;
      };
    };
  };
}
