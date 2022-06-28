local TimeInSeconds = {}

TimeInSeconds.Second = 1
TimeInSeconds.Minute = 60 * TimeInSeconds.Second
TimeInSeconds.Hour = 60 * TimeInSeconds.Minute
TimeInSeconds.Day = 24 * TimeInSeconds.Hour
TimeInSeconds.Week = 7 * TimeInSeconds.Day
TimeInSeconds.Month = 30 * TimeInSeconds.Day
TimeInSeconds.Year = 12 * TimeInSeconds.Month

return TimeInSeconds
