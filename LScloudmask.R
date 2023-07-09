#################### Landsat cloud masking function ############################
################################################################################
# Minnert Wijnads ## 07/07/2023 ################################################
################################################################################


######### DESCRIPTION:

# This function applies a cloud mask over Level-2 Surface Reflectance imagery 
# using the Landsat Quality Assessment band. 
#
# The function accepts multiple inputs. If more than one raster files needs to 
# be cloud masked a list can be given as input. If the Quality Assessment band
# is not given the function will assume the QA band is in the list and will
# extract the QA band using the Landsat naming convention (identifier QA_PIXEL).
# Landsat Collection 2 Level-2 Product Bundle, once loaded as a list type,
# can immediately be used as input.
# If the QA_band is given the function will use this rasterLayer instead.
#
# The function also works for single rasterLayers. In this case the QA band should
# always be given


# The function has the following arguments:
# input:       rasterLayer file or list of rasterLayer files to perform cloud masking on.
#              Can also contain the QA_band
#
# QA_band      NULL or the quality assessement band as a rasterLayer file
#              Default is NULL
#
# sensor:      "TM" or "OLI" 
#               Default is OLI. The LS 4,5 and 6 mission use TM/ETM+ sensors LS 8 and
#               9 mission use OLI sensors
#
# confidence:  "medium/high" or "high"
#               Default is high
#               Determines the confidence level of the pixels to be masked.
#               Medium/high cloud confidence has a larger chance of wrongly identifying
#               pixels as clouds. Correct classification is scene dependent.
#
# snow:         TRUE or FALSE
#               Option to also include the masking of high confidence snow pixels

# Depending on the input type this function either generates 
# 1) a list of rasterLayer files with cloud affected pixels set to NA
#    The structure of the list should be identical to the original input, with the
#    quality assessement band is removed.
# or
# 2) a rasterLayer file with cloud affected pixels set to NA.

# Package dependecies:
# raster

LScloudmask <- function(input, QA_band = NULL, sensor = "OLI", confidence = "medium/high", snow = FALSE) {
  if (sensor == "TM") { # If sensor type is TM/ETM+, use pixel values found in the Landsat 5/7 Science Product Guide
    if (confidence == "high") {
      cloud_vals <- c(5969, 5760, 5896, 7440, 7568, 7696, 7824, 7960, 8088, 1366)
    } else if (confidence == "medium/high") {
      cloud_vals <- c(5896, 7440, 7568, 7696, 7824, 7960, 8088, 13664)
    }
    if (snow) {
      cloud_vals <- c(cloud_vals, 13664)
    }
  } else if (sensor == "OLI") { # If sensor type is TM/ETM+, use pixel values found in the Landsat 8/9 Science Product Guide
    if (confidence == "high") {
      cloud_vals <- c(23888, 23952, 24088, 24216, 24344, 24472, 54596, 54852, 55052)
    } else if (confidence == "medium/high") {
      cloud_vals <- c(22080, 22144, 22280, 23888, 23952, 24088, 24216, 24344, 24472, 54596, 54852, 55052)
    }
    if (snow) {
      cloud_vals <- c(cloud_vals, 30048)
    }
  }
  
  if (is.null(QA_band)) { # If there is no QA_band as input, assume QA band is in the input list
    QA_raster <- input[[which(grepl("PIXEL", names(input)))]]   # From the input list select the QA raster
    cloud_mask <- is.element(QA_raster, cloud_vals)             # create cloud mask from the QA raster
    
    input <- input[-which(grepl("PIXEL", names(input)))]        # QA raster is no longer needed and can be removed
    
    input <- lapply(input, function(i) {
      i[which(cloud_mask)] <- NA  # Change every pixel corresponding with clouds in the QA raster to NA value in all the other raster files
      return(i)
    })
  } else { # If QA_band is given, QA_band should be used as the QA_raster
    QA_raster <- QA_band
    cloud_mask <- is.element(QA_raster, cloud_vals)  # create cloud mask from the QA raster
    
    if (is.list(input)) { # If the input type is a list containing multiple rasterLayer files a list apply (lapply) should be used
      input <- lapply(input, function(i) {
        i[which(cloud_mask)] <- NA  # Change every pixel corresponding with cloud in the QA raster to NA value in all the other raster files
        return(i)
      })
    } else {  # if the input is not a list, assume the input is a single rasterLayer file
      input[which(cloud_mask)] <- NA 
    }
  }
  
  return(input)
}

