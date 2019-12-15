function k = mid_tread_quant(x, delta)

k = sign(x) * delta .* floor( abs(x)/delta + 1/2 );

end