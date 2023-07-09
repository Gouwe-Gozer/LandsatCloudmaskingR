################## Landsat product bundle cloud masking ########################
################################################################################
#### 09/07/2023 ################################################################
#### GouweGozer ################################################################
################################################################################

### Description

# This script performs cloud masking on all raster files in a Landsat
# Collection 2 Level-2 Product Bundle using the dedicated LScloudmask function
# The resulting raster files are saved as .TIF in a directory of your choosing

# The user should fill in the USER VARIABLES below. The rest of the script needs
# no further editing

############################## USER VARIABLES ##################################

# Set the path to the Landsat Product Bundle directory
# (e.j. directory <- "C:/Users/User/OneDrive/Documents/LT05_L2SP_233077_19890325_20200916_02_T1")
PBdirectory <- " "

# Set the path to the directory where the processed raster files should be saved
save_directory <- " "

# Cloud mask settings
sensor <- "TM"         # set sensor type: "TM" for Landsat 5-7, "OLI" for Landsat 8/9
confidence <- "high"   # set the cloud confidence level: "high" or "medium/high"
snow <- FALSE          # option to also mask high confidence snow covered pixels: TRUE or FALSe




########################### Implementation Code ################################

# From here on out no additional user input is required

### Initialisation

# See if raster package is already downloaded to library
if (!require("raster", quietly = TRUE)) { # if not
  install.packages("raster")              # download package
}

library(raster)          # for importing & processing raster files

# Create the cloud masking function
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
# For more information on LScloudmask see the stand-alone script

# Look in the Landsat Product Bundle directory for all files ending with .TIF
file_list <- list.files(PBdirectory, pattern = "\\.TIF$", recursive = TRUE, full.names = TRUE)

# Load the raster files as a list type and perform cloud masking
raster_files <- lapply(file_list, raster)
# Assign original names
names(raster_files) <- basename(file_list)
# Apply cloud masking
raster_files <- LScloudmask(input = raster_files,
                            sensor = sensor,
                            confidence = confidence, 
                            snow = snow)

# Write raster to save directory
lapply(seq_along(raster_files), function(i) {
  raster_file <- raster_files[[i]]
  writeRaster(raster_file,
              filename = paste0(save_directory, "/",names(raster_files)[i]),
              format = "GTiff",
              overwrite = TRUE,
              datatype = 'INT2U',
              NAflag = 1)
})