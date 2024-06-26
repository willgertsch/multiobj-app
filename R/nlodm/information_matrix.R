# information matrix
# x: array of design points
# w: array of weights
# theta: array of parameter values
# most general case
# grad_fun: gradient function to use
# binary_response: set to true to adjust for non-constant variance in binomial response
# dr_fun: dose response function for use with binary response
M.nonlinear = function(x, w, theta, grad_fun, binary_response, dr_fun) {

  IM = 0
  for (i in 1:length(x)) {

    if (binary_response) {
      p_i = dr_fun(x[i], theta)
      v_i = 1/(p_i * (1 - p_i)) # elementary information
    }
    else
      v_i = 1

    IM_i = w[i] * grad_fun(x[i], theta) %*% t(grad_fun(x[i],theta)) * v_i
    IM = IM + IM_i
  }
  IM
}

# return a list of information matrices
# treats theta as a matrix
# this is used when plotting the equivalence theorem test
# binary_response: set to true to adjust for non-constant variance in binomial response
# dr_fun: dose response function for use with binary response
M.nonlinear.list = function(x, w, theta, grad_fun, binary_response, dr_fun) {

  M.list = list()
  p = nrow(theta)
  for (i in 1:p) {
    M.list[[i]] = M.nonlinear(x, w, theta[i, ], grad_fun, binary_response, dr_fun)
  }

  return(M.list)
}

# information matrices for finding exact designs
# general non-linear
# binary_response: set to true to adjust for non-constant variance in binomial response
# dr_fun: dose response function for use with binary response
M.nonlinear.exact = function(x, theta, grad_fun, binary_response, dr_fun) {

  IM = 0
  for (i in 1:length(x)) {

    if (binary_response) {
      p_i = dr_fun(x[i], theta)
      v_i = 1/(p_i * (1 - p_i)) # elementary information
    }
    else
      v_i = 1

    IM_i = grad_fun(x[i], theta) %*% t(grad_fun(x[i],theta)) * v_i
    IM = IM + IM_i
  }
  IM
}
