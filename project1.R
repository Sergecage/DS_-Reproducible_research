setwd("C:/Users/���������/Desktop/serg/data/reproducible research")
library(data.table)
##AMD stands for activity monitoring data
AMD<-read.csv("activity.csv", colClasses=c('numeric', 'character', 'numeric'))
head(AMD)
str(AMD)
names(AMD)
is.na(AMD)
library(lattice)
AMD$date<-as.Date(AMD$date, "%Y-%m-%d")
View(AMD)
library(plyr)
AMD1<-subset(AMD, is.na(AMD$steps)==FALSE)
##totalED stands for total number of steps taken from each day
totalED<-ddply(AMD1,.(date),summarise, steps=sum(steps))

hist(totalED$steps, breaks = 20, main="Number of Steps", 
     xlab="Total number of steps taken each day", ylab = "Number of Days", col="yellow")
dev.copy(png,"Steps.png", width=480, height=480)
dev.off()
##Calculate and report the mean and median of the total number of steps taken per da
mean(totalED$steps)
#[1] 10766.19
median(totalED$steps)
##[1] 10765

##Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) 
## and the average number of steps taken,  averaged across all days (y-axis)
##Interval stands for average 
Interval <- ddply(AMD1, .(interval), summarise, steps=mean(steps))
plot(Interval$interval, Interval$steps,axes = FALSE, type="l", col="red", xlab="Time", ylab="Average Number of Days",
     main="Average Daily Activity Pattern")
axis(1,at=c(0,600,1200,1800,2400), label = c("0:00","6:00","12:00","18:00","24:00"))
axis(2)
dev.copy(png,"Daily Activity pattern.png", width=480, height=480)
dev.off()
Interval[which.max(Interval$steps),]
##     interval    steps
##104      835 206.1698
## Interval shows 835 so it means 8:35, if we add 5 minutes we ger from 8:35 to 8:40
##this is the interval, on average across all the days in the dataset, 
##contains the maximum number of steps

##Imputing missing values
##Calculate and report the total number of missing values in the dataset
##(i.e. the total number of rows with NAs)
sum(is.na(AMD$steps))
##[1] 2304

##Devise a strategy for filling in all of the missing values in the dataset. 
##The strategy does not need to be sophisticated. 
##For example, you could use the mean/median for that day, or the mean for that 5-minute interval, etc.
##We repleced NA with 5 minutes interval

##Create a new dataset that is equal 
##to the original dataset but with the missing data filled in
newdata <- AMD

for (i in 1:nrow(newdata)){
  if (is.na(newdata$steps[i])){
    newdata$steps[i] <- Interval$steps[which(newdata$interval[i] == Interval$interval)]}
}

newdata<- arrange(newdata, interval)
##Make a histogram of the total number of steps taken each day and Calculate 
##and report themean and median total number of steps taken per day
newdata1 <- ddply(newdata, .(date), summarise, steps=sum(steps))
hist(newdata1$steps, breaks = 20, main="Number of Steps", xlab="Total number of steps taken each day", ylab = "Number of Days", col="blue")
dev.copy(png,"NA steps.png", width=480, height=480)
dev.off()
mean(newdata1$steps)
##[1] 10766.19
median(newdata$steps)
##[1] 0

abs(mean(totalED$steps)-mean(newdata1$steps))
##[1] 0
abs(median(totalED$steps)- median(newdata1$steps))/median(totalED$steps)
##[1] 0.0001104207
totalDif <- sum(newdata$steps) - sum(AMD1$steps)
totalDif
##[1] 86129.51

##Create a new factor variable in the dataset with two levels -- "weekday"
##and "weekend" indicating whether a given date is a weekday or weekend day.
Sys.setlocale("LC_TIME", "English")
##[1] "Russian_Russia.1251"
newdata$weekdays <- weekdays(as.Date(newdata$date))
newdata$weekdays <- ifelse(newdata$weekdays %in% c("Saturday", "Sunday"),"weekend", "weekday")
##Make a panel plot containing a time series plot  of the 5-minute interval (x-axis) 
##and the average number of steps taken, averaged across all weekday days or weekend days (y-axis).
##The plot should look something like the following, 
##which was created using simulated data:
stepsaverage <- ddply(newdata, .(interval, weekdays), summarise, steps=mean(steps))
xyplot(steps ~ interval | weekdays, data = stepsaverage, layout = c(1, 2), type="l", xlab = "Interval", ylab = "Number of steps")
dev.copy(png,"days.png", width=480, height=480)
dev.off()
