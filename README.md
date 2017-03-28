VoICE
========
Vocal Inventory Clustering Engine

Zachary Burkett

http://www.nature.com/articles/srep10237

VoICE is for analysis of bird songs. If you're interested in rodent ultrasonic vocalizations, go to [VoICE_USV](https://github.com/zburkett/VoICE_USV).

Author/Support
==============
Zachary Burkett, zburkett@ucla.edu

Software Tutorial/Walkthrough
=============================
Video Tutorials:
  * [Installation](https://youtu.be/6yVNSFihYKs)
  * [Clustering a single recording session](https://youtu.be/Lr29XMDq1s4)
  * Comparing two recording sessions (Coming soon!)

Please see the video tutorials for an example analysis using VoICE. We also have the  [walkthrough](https://github.com/zburkett/VoICE/blob/master/walkthrough.pdf) for the previous version of VoICE available, though it does not reflect changes made between that which launched with the software and the current version.

Directory Contents
==================
  * MATLAB: Contains all MATLAB functions
  * R: Contains all R functions
  * sample_data: Contains an example dataset, see walkthrough.
  * README.md: README, you're looking at it
  * walkthrough.pdf: A brief overview of VoICE's functionality using the sample_data.

Installation
============
1. Complete the steps below specific to your operating system.

2. Download this directory and unzip to a location in which you would like to store the software.

3. Add the unzipped directory with subfolders to your MATLAB path.

4. Typing 'voice' at the MATLAB command prompt will launch the software.

5. The intial launch of VoICE will check your system for installed dependencies and the necessary R packages. This will only need to happen once.

MATLAB
======
VoICE was developed for MATLAB R2013a. Newer versions break compatibility with some of VoICE's functionality. If you are using a version newer than R2013a, your license will allow you to download an older version.

Visit [Mathworks Downloads](https://www.mathworks.com/downloads/web_downloads/select_release) and install a copy of R2013a.

Mac OS X
--------
VoICE relies on free external software (R, SoX, and ImageMagick) that must be installed prior to running VoICE. VoICE will check for these programs on launch and halt if they are not found. If they are installed but not in the system path, VoICE will attempt to add them.

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

VoICE also relies on R, which is already included with Mac OS X. If you run into errors and need to reinstall R, please download and install R from https://cloud.r-project.org and or by Homebrew:
```bash
# Install Homebrew if not already done for SoX:
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install R
brew tap homebrew/science
brew install Caskroom/cask/xquartz
brew install r
```

Windows
-------
VoICE relies on external software (R, SoX and ImageMagick) that must be installed prior to running VoICE. VoICE will check for these programs on launch and halt if they are not found. If they are installed but not in the system path, VoICE will attempt to add them. Unfortunately, there is no convenient command line tool for installing this software. Please visit each website, download the software appropriate for your version of Windows, then perform a standard install.

R is available here: https://cloud.r-project.org

SoX is available here: https://sourceforge.net/projects/sox/files/sox/

ImageMagick is available here: https://www.imagemagick.org/script/download.php#windows [Note: If you already have an older version of ImageMagick for Windows installed, it may need updating.]

Software Requirements
=====================
  * MATLAB (Tested up through R2013a; unsure of support for more recent versions)
  * MATLAB Parallel Processing Toolbox (Not required by VERY STRONGLY recommended)
  * MATLAB Signal Processing Toolbox
  * R (See installation, above)
  * SoX (See installation, above)
  * ImageMagick (See installation, above)
  
Limitations
===========
VoICE operates on a directory containing an SAP (http://soundanalysispro.com) feature batch (as a .xls file; .xlsx files *will not* work!) and the .WAV files from which the feature batch was constructed. VoICE will clip the individual syllables from their parent .WAV files. The construction of the feature batch is at the user's discretion. Best results come from the manual annotation of syllable start/stop boundaries, though this is considerably more time consuming than thresholding.

Developers
==========
Pull requests are welcomed!