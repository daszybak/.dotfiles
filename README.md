# Interactive installation
curl -fsSL https://raw.githubusercontent.com/daszybak/.dotfiles/main/install.sh | bash

# Force yes installation
curl -fsSL https://raw.githubusercontent.com/daszybak/.dotfiles/main/install.sh | bash -s -- -y

# Local installation
git clone git@github.com:daszybak/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh -y

