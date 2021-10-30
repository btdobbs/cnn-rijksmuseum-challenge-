# Steps for Experiment Reproduction
## Data
To retrieve data for the experiment, please try the data references from one of the following articles:

-http://ieeexplore.ieee.org/document/7123719/
-https://doi.org/10.1145/2578726.2578791

If the links are dead from the above references, please try the source.

-https://www.rijksmuseum.nl/en/research/conduct-research/data
-https://www.rijksmuseum.nl


If you need to go directly to the source, you may need to filter images that were not in the data set at the time of the experiment.  The file names of all images used in experiments is located in the images.txt file in the root of this repository.

Once the data is identified and filtered, you will need to run PrepareRijksFolders.m to prepare the image folders.  The image locations will need to be modified based on your system's folder structure.
## Experiment
Use MATLAB to run the code in matlab/resnet given the data downloaded in the previous step.  Note, the .mat files used for transfer learning are binary and are not added to this repository.  Both of these .mat files are reproducable by creating and saving a sample resnet 18 and 101 experiment in MATLAB.  The DecayingResNet.m files is the main driver for the experiment.
## Measures
Using the confusion matrix output of the experiment, run the MATLAB code in matlab/measures to reproduces measures and analysis results.
