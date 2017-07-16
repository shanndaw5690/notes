# https://bart6114.github.io/jug/articles/jug.html

# devtools::install_github("Bart6114/jug")
# devtools::install_github("Bart6114/jug.parallel")
 
library(jug)

jug() %>% 
    get(path = "/my_path", function(req, res, err) {
        "get test 1, 2, 3 on path /my_path"
    }) %>% 
    simple_error_handler() %>% 
    serve_it()

# with your own functions

say_hello <- function(name) { paste("hello", name, "!") }

jug() %>% 
    get(path = "/hello", decorate(say_hello)) %>% 
    serve_it()

# expose machine learning model

library(FFTrees)

data("titanic")
head(titanic)

mod <- FFTrees(formula = survived ~ ., data = titanic)
summary(mod)
plot(mod)

predict(mod, data = data.frame(survived = 0, class = "first", age = "adult", sex = "male"))

predict_survival <- function(class, age, sex) {
    y <- predict(mod, data = data.frame(survived = 0, class = class, age = age, sex = sex))
    return(y)
}

predict_survival("first", "child", "male")

jug() %>% 
    post("predict", decorate(predict_survival)) %>% 
    simple_error_handler() %>% 
    serve_it()

# parallel

library(jug.parallel)

jug() %>% 
    post("predict", decorate(predict_survival)) %>% 
    simple_error_handler_json() %>% 
    serve_it_parallel(processes = 4)
