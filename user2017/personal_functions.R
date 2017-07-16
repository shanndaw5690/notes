kink <- function(x, intercept, slopes, breaks) {
    
    assertive::assert_is_of_length(intercept, n = 1)
    assertive::assert_is_of_length(breaks, n = length(slopes) - 1)
    
    intercepts <- c(intercept)
    
    for(i in 1:length(slopes)-1) {
        intercept <- intercepts[i] + slopes[i] * breaks[i] - slopes[i+1] * breaks[i]
        intercepts <- c(intercepts, intercept)
    }
    
    i = 1 + findInterval(x, breaks)
    y = slopes[i] * x + intercepts[i]
    
    return(y)
    
}