
#Steps when making a new release:

#1. Update version number:
#   i. In AToMPM - client/constants.js
#   ii. In documentation - doc/conf.py
#   iii. In Node - package.json
#2. Push these changes to GitHub
#3. Create a new release on GitHub
#4. The tag should be something like v0.8.0
#5. Run this script, which will download the latest tagged version
#   and package everything
#   - Run it for the Python2 and the Python3 version
#   - Fix up the files in the package
#        - Delete the unused Python directory in each zip
#6. Upload the package .zip to the release on GitHub
#7. Publish to npm repo

version="v0.8.2"

package_python3=true

#Python2
portable_python_url="http://elvis.rowan.edu/mirrors/portablepython/v2.7/PortablePython_2.7.6.1.exe"

igraph_whl_url="https://github.com/AToMPM/atompm/releases/download/v0.7.0/python_igraph-0.7.1.post6-cp27-cp27m-win32.whl"

#Python3

python_version="3.6.5"

winpython_url="https://github.com/winpython/winpython/releases/download/1.10.20180404/WinPython32-3.6.5.0Zero.exe"

igraph3_whl_url="https://github.com/AToMPM/atompm/releases/download/v0.7.0/python_igraph-0.7.1.post6-cp36-cp36m-win32.whl"

#platform

nodejs_zip_url="https://nodejs.org/dist/v8.11.3/node-v8.11.3-win-x64.zip"

chrome_url="https://newcontinuum.dl.sourceforge.net/project/portableapps/Google%20Chrome%20Portable/GoogleChromePortable_67.0.3396.87_online.paf.exe"

manual_url="https://media.readthedocs.org/pdf/atompm/latest/atompm.pdf"

#$(curl --silent "https://api.github.com/repos/AToMPM/atompm/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')

echo "Packaging version: $version"

#echo $nodejs_zip_url
#echo $portable_python_url
#echo $igraph_whl_url

# STEPS
# 1. Download Python
#   a. Currently, this is PortablePython from
#   b. http://portablepython.com/wiki/PortablePython2.7.6.1/
function get_PP() {
    echo "Downloading PortablePython"
    
    PP_file=$(basename $portable_python_url)
    echo $PP_file

    if [ ! -f $PP_file ]; then
        echo "Downloading $portable_python_url" 
        curl -O $portable_python_url
    fi

    #   c. Install PortablePython
    #TODO: Automate installation
    #Z:\home\dcx\Projects\AToMPM\packaging\atompm-portable\platform\PortablePython27\
    #No modules and no core editors
    #Except for the Six package
    wine $PP_file

    #   d. Install pip on the packaging machine (Python2 version)

    cd atompm-portable/platform/PortablePython27/App

    # INSTALL PIP
    #TODO: Fix this installation
    #wine scripts/easy_install.exe pip
    #TODO: Replace with above
    #pip2 install --upgrade --target=Lib/site-packages/ pip

    #INSTALL IGRAPH
    igraph_whl_file=$(basename $igraph_whl_url)
    echo $igraph_whl_file

    #if [ ! -f $igraph_whl_file ]; then
    #    echo "Downloading $igraph_whl_url" 
    #    curl -O $igraph_whl_url
    #fi

    #MUST HAVE WHL FILE LOCALLY FOR NOW
    cd ../../../..
    unzip -o $igraph_whl_file -d atompm-portable/platform/PortablePython27/App/Lib/site-packages/
}

function get_WP() {
    echo "Downloading WinPython"
    
    WP_file=$(basename $winpython_url)
    echo $WP_file

    if [ ! -f $WP_file ]; then
        echo "Downloading $winpython_url" 
        curl -O $winpython_url
    fi

    #   c. Install WinPython
    #TODO: Automate installation
    #Z:\home\dcx\Projects\AToMPM\packaging\atompm-portable\platform\WinPython\
    #No modules and no core editors
    #Except for the Six package
    wine $WP_file

    #   d. Install pip on the packaging machine (Python2 version)

    cd atompm-portable/platform/WinPython/python-$python_version
    
    # INSTALL IGRAPH
    #TODO: Fix this installation
    #wine Scripts/pip3 install python-igraph
    
    igraph3_whl_file=$(basename $igraph3_whl_url)
    echo $igraph3_whl_file

    #if [ ! -f $igraph_whl_file ]; then
    #    echo "Downloading $igraph_whl_url" 
    #    curl -O $igraph_whl_url
    #fi

    #MUST HAVE WHL FILE LOCALLY FOR NOW
    cd ../../../..
    unzip -o $igraph3_whl_file -d atompm-portable/platform/WinPython/python-$python_version/Lib/site-packages/
}

function get_nodejs() {
    echo "Downloading NodeJS"
    # 2. Download node.js https://nodejs.org/en/download/
    #   a. Choose Windows Binary (.zip)

    nodejs_file=$(basename $nodejs_zip_url)
    echo $nodejs_file

    if [ ! -f $nodejs_file ]; then
        echo "Downloading $nodejs_zip_url" 
        curl -O $nodejs_zip_url
    fi

    unzip -o $nodejs_file -d atompm-portable/platform/
    mv atompm-portable/platform/node-v* atompm-portable/platform/NodeJS
}

# 3. Add ChromePortable

function get_chrome() {
    echo "Downloading PortableChrome"
    chrome_file=$(basename $chrome_url)
    echo $chrome_file

    if [ ! -f $chrome_file ]; then
        echo "Downloading $chrome_url" 
        curl -O $chrome_url
    fi

    #TODO: Automate installation
    #Z:\home\dcx\Projects\AToMPM\packaging\atompm-portable\platform\GoogleChromePortable
    wine GoogleChromePortable_67.0.3396.87_online.paf.exe
}

# 4. Add AToMPM files
function add_atompm () {

    echo "Adding AToMPM"
    
    rm -rf atompm-portable/atompm
    cd atompm-portable
    git clone --depth 1 https://github.com/AToMPM/atompm.git
    cd atompm
    git checkout $version
    rm -rf .git
    
    npm install --production
    
    cd ../..
}


# 5. Add Windows batch scripts

function add_batch_scripts (){
    echo "Adding batch scripts"
    cp windows_scripts/*.bat atompm-portable/
}
# 6. Add manual

function add_manual(){
        echo "Adding manual"
        manual_filename="atompm-userguide.pdf"
        
        curl $manual_url -o $manual_filename
        cp $manual_filename atompm-portable/
        rm $manual_filename
}

###MAIN######

if [ "$package_python3" = false ] ; then
    if [ ! -d ./atompm-portable/platform/PortablePython27 ]; then
        get_PP
    fi
    
else
    if [ ! -d ./atompm-portable/platform/WinPython ]; then
        get_WP
    fi  
fi

if [ ! -d ./atompm-portable/platform/NodeJS ]; then
    get_nodejs
fi

if [ ! -d ./atompm-portable/platform/GoogleChromePortable ]; then
    get_chrome
fi

add_atompm
add_batch_scripts
add_manual

rm atompm-portable.zip

if [ "$package_python3" = false ] ; then
    zip -r atompm-portable-python2.zip atompm-portable/
else
    zip -r atompm-portable-python3.zip atompm-portable/
fi

