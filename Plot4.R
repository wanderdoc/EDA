# First filter the data.
# The filtered data will be saved 
# in the file "out.txt" in the working directory.

# Check where we are:
getwd()

########################################################
# If you wish to download and unzip the file here,
# please uncomment the following four script lines.
########################################################


# myUrl  = "https://d396qusza40orc.cloudfront.net/exdata/data/household_power_consumption.zip"
# myZip  = "./household_power_consumption.zip"
# download.file(myUrl, myZip)
# unzip(myZip)


############################################################
# Or just unzip the file "household_power_consumption.txt"
# in the working directory using the program of your choice.
############################################################

# Continue with the unzipped source file.

myFile = "./household_power_consumption.txt"
myFiltered = "./out.txt"

# Delete the file "out.txt" if it already exists,
# since the file will be written in the append mode.
unlink(myFiltered)

file_in <- file(myFile, "r")
file_out <- file(myFiltered,"a")

myBlock <-readLines(file_in, n = 1)
writeLines(myBlock, file_out) # Copy the header.

Blocksize <- 5000 
# It takes 19-20 sec. to filter the data
# with this blocksize.

while(length(myBlock)) {
  ind <- grep("^0?(1|2)/0?2/2007", perl=TRUE,  myBlock)
  if (length(ind)) writeLines(myBlock[ind], file_out)
  myBlock <- readLines(file_in, n=Blocksize)
}


close(file_in)
close(file_out)

########################################################
# If you wish, delete the large source files here:
#
# The unzipped file:
# unlink(myFile)

# The zipped file:
# unlink(myZip)
#
########################################################

# Now reading the filtered data.
myData <- read.csv2("./out.txt", 
                    header = T, 
                    na.strings="?",
                    stringsAsFactors = FALSE)

# Make a Datetime column.
myData$Datetime <- as.POSIXct(
  paste(myData$Date, myData$Time), 
  format="%d/%m/%Y %H:%M:%S")

# Check if we have missing data:
any(is.na(myData)) # returns FALSE.

# Plotting.
# Plot 4.

# Save our locale.
myLocale<-Sys.setlocale("LC_TIME")
# Set English for day labels.
Sys.setlocale("LC_TIME", "English")

png("./Plot4.png", width = 480, height = 480, units = "px")
# Set multiplot.
par(mfrow = c(2, 2))

# Top left.
with (myData,
      plot(Datetime, as.numeric(Global_active_power),
           type = "lines",
           ylab = "Global Active Power (kilowatts)",
           xlab = "",
           xaxt = "n"
      )
)
axis.POSIXct(1, myData$Datetime, format = "%a" )

# Top right.
with (myData,
      plot(Datetime, as.numeric(Voltage),
           type = "lines",
           ylab = "Voltage",
           xlab = "datetime",
           xaxt = "n"
      )
)
axis.POSIXct(1, myData$Datetime, format = "%a" )

# Bottom left.
with (myData,
      plot(Datetime, as.numeric(Sub_metering_1),
           type = "lines",
           col="grey20",
           lwd = 1,
           ylab = "Energy sub metering",
           xlab = "",
           xaxt = "n"
      )
)
with(myData, lines(Datetime, as.numeric(Sub_metering_2),col="red", lwd = 1))
with(myData, lines(Datetime, as.numeric(Sub_metering_3),col="blue",lwd = 1))
legend("topright", 
       col = c("grey20", "red", "blue"), lwd = 1,
       legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"),
       cex = 0.75,
       bty = "n",
       y.intersp = 0.75
)
axis.POSIXct(1, myData$Datetime, format = "%a" )

# Bottom right.
with (myData,
      plot(Datetime, as.numeric(Global_reactive_power),
           type = "lines",
           ylab = "Global_reactive_power",
           xlab = "datetime",
           xaxt = "n"
      )
)
axis.POSIXct(1, myData$Datetime, format = "%a" )


dev.off()

# Unset multiplot.
par(mfrow = c(1, 1))

# Restore our locale.
Sys.setlocale("LC_TIME", myLocale)

