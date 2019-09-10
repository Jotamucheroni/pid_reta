function Is = sobel(Ie)
  Is = zeros(size(Ie)(1),size(Ie)(2));
  Ie = double(Ie);

  for i=2:size(Ie)(1)-1
    for j=2:size(Ie)(2)-1
      mx = Ie(i-1, j-1) + 2 * Ie(i-1, j) + Ie(i-1, j+1) - Ie(i+1, j-1) - 2 * Ie(i+1, j) - Ie(i+1, j+1);
      my = -Ie(i-1, j-1) + Ie(i-1, j+1) - 2 * Ie(i, j-1) + 2 * Ie(i, j+1) - Ie(i+1, j-1) + Ie(i+1,j+1);
      Is(i,j) = sqrt(mx^2 + my^2);
    end
  end
  
  Is /= max(Is(:));
end