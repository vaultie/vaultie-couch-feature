USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

# Default: Exit on any failure.
set -e

# Clean up
rm -rf /var/lib/apt/lists/*

# Setup STDERR.
err() {
    echo "(!) $*" >&2
}

if [ "$(id -u)" -ne 0 ]; then
    err 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi



apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}









install_using_apt() {
    # Install dependencies
    check_packages apt-transport-https curl ca-certificates gnupg2 sudo

    # Import the repository signing key
    curl -fsSL https://couchdb.apache.org/repo/keys.asc | gpg --dearmor -o /usr/share/keyrings/couchdb-archive-keyring.gpg 
    
    # Create the file repository configuration
    echo "deb [signed-by=/usr/share/keyrings/couchdb-archive-keyring.gpg] https://apache.jfrog.io/artifactory/couchdb-deb/ ${VERSION_CODENAME} main" | sudo tee /etc/apt/sources.list.d/couchdb.list


    # Update lists
    apt-get update -yq
    
    echo "couchdb couchdb/adminpass_again password admin" | sudo debconf-set-selections
    echo "couchdb couchdb/adminpass  password admin" | sudo debconf-set-selections
    echo "couchdb couchdb/cookie string cookie" | sudo debconf-set-selections
    echo "couchdb couchdb/nodename string couchdb@localhost" | sudo debconf-set-selections
    echo "couchdb couchdb/mode select standalone" | sudo debconf-set-selections
    echo "couchdb couchdb/bindaddress string 127.0.0.1" | sudo debconf-set-selections
    echo "couchdb couchdb/postrm_remove_databases boolean false" | sudo debconf-set-selections

    sudo apt install -y couchdb
}
sudo init 3
export DEBIAN_FRONTEND=noninteractive

# Source /etc/os-release to get OS info
. /etc/os-release
architecture="$(dpkg --print-architecture)"

install_using_apt

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"