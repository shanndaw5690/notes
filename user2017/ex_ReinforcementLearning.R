# devtools::install_github("nproellochs/ReinforcementLearning")

library(ReinforcementLearning)
library(tidyverse)
library(stringr)
library(glue)

# Each training example consists of a state transition tuple (s,a,r,s_new):
# § s The current environment state.
# § a The selected action in the current state.
# § r The immediate reward received after transitioning from the current state to the next state. 
# § s_new The next environment state.

# Input data must be a dataframe in which each row represents a state transition tuple (s,a,r,s_new)

data('tictactoe')
View(tictactoe)

tictactoe <- tictactoe %>% 
    mutate(State = str_replace_all(State, pattern = "B", replacement = "O")) %>% 
    mutate(NextState = str_replace_all(NextState, pattern = "B", replacement = "O")) %>% 
    mutate(State = str_replace_all(State, pattern = "\\.", replacement = "\\_")) %>% 
    mutate(NextState = str_replace_all(NextState, pattern = "\\.", replacement = "\\_"))

x <- "_XOOOXXXO"

display_board <- function(x) {
    cat(sep = "",
        str_sub(x, 1, 3), "\n",
        str_sub(x, 4, 6), "\n",
        str_sub(x, 7, 9), "\n")
}

display_board(x)

tictactoe[322, "NextState"] %>% display_board()

small_toe <- tictactoe %>% filter(row_number() <= 100000)

# learn policy

control <- list(
    alpha = 0.2, # learning rate (0 - 1), at 0 nothing is learned
    gamma = 0.4, # discount factor (0 - 1), importance of future rewards, 0 is short-sighted
    epsilon = 0.1 # exploration parameter (0 - 1), 0 is full randomness, 
)

model <- ReinforcementLearning(
    data = tictactoe,
    s = "State", 
    a = "Action", 
    r = "Reward", 
    s_new = "NextState", iter = 1, control = control, verbose = TRUE)

policy(model)
plot(model)

learned <- tibble("State" = names(model$Policy), "Action" = model$Policy)

learned %>% filter(State == "OO_X__XOX") %>% pull(State) %>% display_board()

# gird world

states <- c("s1", "s2", "s3", "s4") 
actions <- c("up", "down", "left", "right")

env <- function (state, action) {
    next_state <- state
    if (state == state("s1") && action == "down")
        next_state <- state("s2")
    if (state == state("s2") && action == "up")
        next_state <- state("s1")
    if (state == state("s2") && action == "right")
        next_state <- state("s3")
    if (state == state("s3") && action == "left")
        next_state <- state("s2")
    if (state == state("s3") && action == "up")
        next_state <- state("s4")
    if (next_state == state("s4") && state != state("s4")) {
        reward <- 10 }
    else {
        reward <- -1
    }
    return(list(NextState = next_state, Reward = reward)) 
}

df <- sampleExperience(N = 1000, env = env, states = states, actions = actions)

control <- list(alpha = 0.1, gamma = 0.5, epsilon = 0.1)
model <- ReinforcementLearning(
    df, s = "State", a = "Action", r = "Reward", 
    s_new = "NextState", control = control, iter = 100, verbose = TRUE
)

print(model)
summary(model)
1