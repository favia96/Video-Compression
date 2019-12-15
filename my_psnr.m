function psnr = my_psnr(d)

    psnr = 10 * log10( 255^2 ./ d );

end