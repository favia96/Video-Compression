function mse = my_mse(x,y)

mse = sum((x(:)-y(:)) .^2 ) / length(x(:));

end