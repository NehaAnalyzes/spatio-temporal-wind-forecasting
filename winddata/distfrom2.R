# Set the folder path where your files are located.
folder_path <- "~/work/winddata/"  # Replace with your actual folder path

# Define the reference coordinates.
ref_lat <- 45.33335
ref_long <- -104.41732

# Get a list of all files in the folder.
files <- list.files(path = folder_path, pattern = "^SITE.*\\.CSV$", full.names = TRUE)


# Create a data frame to store the results.
results <- data.frame(file = character(), distance = numeric(), stringsAsFactors = FALSE)

# Process each file.
for (file in files) {
  # Read all lines from the file.
  lines <- readLines(file, warn = FALSE)
  
  # Ensure the file has at least two lines.
  if (length(lines) >= 2) {
    # Extract the second line.
    line2 <- lines[2]
    
    # Use regular expressions to extract latitude and longitude.
    # The pattern looks for the numbers after "SITE LATITUDE:" and "LONGITUDE:".
    lat <- as.numeric(sub(".*SITE LATITUDE:\\s*([0-9.-]+).*", "\\1", line2))
    long <- as.numeric(sub(".*LONGITUDE:\\s*([0-9.-]+).*", "\\1", line2))
    
    # Calculate the Euclidean distance.
    # Note: This is a simple calculation and does not account for Earth curvature.
    distance <- sqrt((lat - ref_lat)^2 + (long - ref_long)^2)
    
    # Append the result to the data frame.
    results <- rbind(results, data.frame(file = file, distance = distance, stringsAsFactors = FALSE))
  } else {
    warning(paste("File", file, "does not contain at least two lines."))
  }
}

# Print the results.
print(results)
results <- results[order(results$distance), ]
print(results)
setwd(folder_path)
write.table(results,file="distancefromsite2.dat",row.names = F)

# Read the CSV file without headers
df <- read.table("~/work/winddata/distancefromsite2.dat", header = T, stringsAsFactors = FALSE)
head(df)


df$distance=as.numeric(df$distance)
df_clean <- na.omit(df)
sum(df$distance[1:234])
df_clean$distance
