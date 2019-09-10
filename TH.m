function [H, theta, rho] = TH(I)
  theta = 0:179;
  diag = floor(sqrt(size(I)(1)^2 + size(I)(2)^2)) + 1;
  rho = -diag:diag;
  H = zeros(size(rho)(2), size(theta)(2));
  
  for x=1:size(I)(1)
    for y=1:size(I)(2)
      if I(x,y) == 1
        for t=theta
          ang = deg2rad(t);
          H( round(x * cos(ang) + y * sin(ang)) + diag + 1, t + 1)++;
        end
      end
    end
  end
end