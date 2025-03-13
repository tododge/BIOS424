################################
#### Plotting mummer output ####
################################

# This code takes a mummer.coords file. it can plot 1 sequence alignment at a time, 
# so make sure to specify your sequences. Give it coordinates too if you want to 
# view a smaller region

plot_mummer <- function(file, seqX, seqY, Xcoords = NULL, Ycoords = NULL, title = NULL, tick = 1e6) {
  # Check if file exists
  if (!file.exists(file)) {
    stop("Error: The specified file does not exist. Please check the file path.")
  }
  
  # Read the input file, skipping the first 4 lines, and assigning column names
  coord <- tryCatch(
    {
      read.csv(file, sep="\t", skip=4, header=FALSE, 
               col.names = c("start1", "end1", "start2", "end2", 
                             "length1", "length2", "perc_similar", "name1", "name2"))
    },
    error = function(e) {
      stop("Error: Unable to read the file. Ensure it is a valid tab-separated file with at least 4 header lines.")
    }
  )
  
  # Check if the required columns exist
  required_cols <- c("start1", "end1", "start2", "end2", "length1", "length2", "perc_similar", "name1", "name2")
  if (!all(required_cols %in% names(coord))) {
    stop("Error: The input file does not have the expected column format. Please verify the file structure.")
  }
  
  # Ensure seqX and seqY are provided
  if (missing(seqX) || missing(seqY)) {
    stop("Error: Both seqX and seqY must be specified.")
  }
  
  # Filter data to keep only alignments between the specified sequences
  filtered_coord <- subset(coord, name1 == seqX & name2 == seqY)
  
  # Check if any data matches the given seqX and seqY
  if (nrow(filtered_coord) == 0) {
    stop("Error: No matching alignments found for the given sequences. Check if seqX and seqY exist in the file.")
  }
  
  # Validate tick value
  if (!is.numeric(tick) || tick <= 0) {
    stop("Error: 'tick' must be a positive numeric value.")
  }
  
  # Set default X and Y coordinate limits if they are not provided
  if (is.null(Xcoords)) {
    Xcoords <- range(c(filtered_coord$start1, filtered_coord$end1), na.rm = TRUE)
  } else if (!is.numeric(Xcoords) || length(Xcoords) != 2) {
    stop("Error: 'Xcoords' must be a numeric vector of length 2 (min and max values).")
  }
  
  if (is.null(Ycoords)) {
    Ycoords <- range(c(filtered_coord$start2, filtered_coord$end2), na.rm = TRUE)
  } else if (!is.numeric(Ycoords) || length(Ycoords) != 2) {
    stop("Error: 'Ycoords' must be a numeric vector of length 2 (min and max values).")
  }
  
  # Create the MUMmer dot plot using ggplot2
  myplot <- ggplot(data = filtered_coord, aes(x = start1, y = start2, xend = end1, yend = end2)) +
    
    # Add alignment segments as lines
    geom_segment(lineend = "butt", lwd = 0.3) +
    
    # Set the theme (removing grid lines for a cleaner look)
    theme_bw(base_size = 8) +
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank()) +
    
    # Adjust the X-axis with tick spacing and labels converted to Mb
    scale_x_continuous(expand = c(0, 0), 
                       breaks = seq(0, Xcoords[2], by = tick), 
                       labels = seq(0, Xcoords[2]/1e6, by = tick/1e6)) +
    
    # Adjust the Y-axis with tick spacing and labels converted to Mb
    scale_y_continuous(expand = c(0, 0), 
                       breaks = seq(0, Ycoords[2], by = tick), 
                       labels = seq(0, Ycoords[2]/1e6, by = tick/1e6)) +
    
    # Ensure aspect ratio is preserved
    coord_fixed(xlim = Xcoords, ylim = Ycoords) +
    
    # Add a title if provided
    ggtitle(title) +
    
    # Rename axes using the sequence names and indicate units (Mb)
    labs(x = paste(seqX, "position (Mb)"), y = paste(seqY, "position (Mb)"))
  
  # Return the final plot
  return(myplot)
}

#setwd("path/to/directory")

plot_mummer("./chr-13_h1.fa_2_chr-13_ref.fa.delta.m.coords", 
            seqX = "chr-13",
            seqY = "chr-13"
)

#plot_mummer("./chr-13_h1.fa_2_chr-13_ref.fa.delta.m.coords", 
#            seqX = "chr-13",
#            seqY = "chr-13",
#            title = "FGS1",
#            Xcoords = c(7e6, 9.2e6),
#            Ycoords = c(7.1e6, 9.65e6),
#            tick=5e5
#)
