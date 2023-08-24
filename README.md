# LandsatCloudmaskingR

### Repository readme
This repository contains an R-function for the cloud masking of Landsat Collection 2 Level-2 Products using the Quality Assessement band (QA_PIXEL)
The function can be found in LScloudmask.R.

The repository also contains a stand-alone script, LandsatProductBundleCloudmasking.R. This is a user-friendly script that takes the path of
a Landsat Collection 2 Level-2 Product Bundle as input and generates cloud masked versions of all raster files contained in the directory as output.

### Function readme
 This function applies a cloud mask over Level-2 Surface Reflectance imagery 
using the Landsat Quality Assessment band. 

The function accepts multiple inputs. If more than one raster files needs to 
be cloud masked a list can be given as input. If the Quality Assessment band
is not given the function will assume the QA band is in the list and will
extract the QA band using the Landsat naming convention (identifier QA_PIXEL).
Landsat Collection 2 Level-2 Product Bundle, once loaded as a list type,
can immediately be used as input.
 f the QA_band is given the function will use this rasterLayer instead.

The function also works for single rasterLayers. In this case the QA band should
always be given


The function has the following arguments:
input:       rasterLayer file or list of rasterLayer files to perform cloud masking on.
             Can also contain the QA_band

QA_band      NULL or the quality assessement band as a rasterLayer file
              Default is NULL

 sensor:      "TM" or "OLI" 
               Default is OLI. The LS 4,5 and 6 mission use TM/ETM+ sensors LS 8 and
               9 mission use OLI sensors

 confidence:  "medium/high" or "high"
               Default is high
               Determines the confidence level of the pixels to be masked*.
               Medium/high cloud confidence has a larger chance of wrongly identifying
               pixels as clouds. Correct classification is scene dependent.

 snow:         TRUE or FALSE
               Option to also include the masking of high confidence snow pixels

 Depending on the input type this function either generates 
 1) a list of rasterLayer files with cloud affected pixels set to NA
    The structure of the list should be identical to the original input, with the
    quality assessement band is removed.
 or
 2) a rasterLayer file with cloud affected pixels set to NA.

*
Option "high" masks all pixels classified as high confidence cloud, high confidence cloud shadow, water with cloud shadow, mid confidence cloud with [high confidence] cloud  mid confidence cloud with [high confidence] shaow over water, high confidence cloud with shadow, high confidence cloud with shadow over water, and additionally for the OLI sensor high confidence cirrus.
Option "medium/high" masks all pixels classified as mid confidence cloud, mid confidence cloud over water, high confidence cloud, high confidence cloud shadow, water with cloud shadow, mid confidence cloud with [high confidence] cloud  mid confidence cloud with [high confidence] shaow over water, high confidence cloud with shadow, high confidence cloud with shadow over water, and additionally for the OLI sensor high confidence cirrus.
For more information on classifications of the quality assessment the Landsat Science Product Guides can be consulted.
