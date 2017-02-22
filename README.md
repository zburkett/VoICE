VoICE
========
Vocal Inventory Clustering Engine

Zachary Burkett

http://www.nature.com/articles/srep10237

Author/Support
==============
Zachary Burkett, zburkett@ucla.edu

Manual
======
Coming Soon.

Directory Contents
==================
  * MATLAB: Contains all MATLAB functions
  * R: Contains all R functions
  * sample_data: Contains an example dataset, see walkthrough in the manual
  * README.md: README, you're looking at it

Installation
=====================
Download this directory and unzip to a location in which you would like to store the software.

Add the unzipped directory with subfolders to your MATLAB path. Optionally, you may remove the .git/ subfolders.

Typing 'voice' at the MATLAB command prompt will launch the software following installation. Please see installation instructions for your operating system, below.

Mac OS X
--------
VoICE relies on free external software (Perl R, SoX, and ImageMagick) that must be installed prior to running VoICE. VoICE will check for these programs on launch and halt if they are not found. If they are installed but not in the system path, VoICE will attempt to add them.

The instructions below will install SoX and ImageMagic, then add them to your system path.

To install SoX:
```bash
# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Once Homebrew installation is finished, install SoX
brew install sox

# Then install ImageMagick
brew install imagemagick
```

VoICE also relies on R and Perl, which are already included with Mac OS X. If either or both are, please download and install R from https://cloud.r-project.org and Perl from https://www.perl.org/get.html or by:
```bash
# Install Homebrew if not already done for SoX:
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install R
brew tap homebrew/science
brew install Caskroom/cask/xquartz
brew install r

# Install Perl
brew install perl
```

Windows
-------
VoICE relies on external software (Perl, R, SoX and ImageMagick) that must be installed prior to running VoICE. VoICE will check for these programs on launch and halt if they are not found. If they are installed but not in the system path, VoICE will attempt to add them. Unfortunately, there is no convenient command line tool for installing this software. Please visit each website, download the software appropriate for your version of Windows, then perform a standard install.

Strawberry Perl is available here: http://strawberryperl.com

R is available here: https://cloud.r-project.org

SoX is available here: https://sourceforge.net/projects/sox/files/sox/

ImageMagick is available here: https://www.imagemagick.org/script/download.php#windows [Note: If you already have an older version of ImageMagick for Windows installed, it may need updating.]

Software Requirements
==============================
  * MATLAB (Tested up through R2015a; unsure of support for more recent versions)
  * MATLAB Parallel Processing Toolbox (Not required by VERY STRONGLY recommended)
  * MATLAB Signal Processing Toolbox
  * R (See installation, above)
  * SoX (See installation, above)
  * ImageMagick (See installation, above)
  * Perl (See installation, above)
  
Limitations
===========
VoICE operates on a directory containing an SAP (http://soundanalysispro.com) feature batch (as a .xls file) and the .WAV files from which the feature batch was constructed. VoICE will clip the individual syllables from their parent .WAV files. The construction of the feature batch is at the user's discretion. Best results come from the manual annotation of syllable start/stop boundaries, though this is considerably more time consuming than thresholding.

Developers
==========
Pull requests are welcomed!