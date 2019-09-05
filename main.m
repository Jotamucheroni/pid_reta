clear;
clc;

pkg load image;

I = rgb2gray(imread('borracha.jpg')); %I = uint8(zeros(xMax,yMax));
xMax = uint8(size(I)(1));
yMax = uint8(size(I)(2));

%for x=21:80
%  for y=21:80
%    I(x,y) = 255;
%  end
%end

%figure;
%imshow(I);
borda = edge(I, 'sobel'); %bordaQuad = edge(I, 'canny');
%figure;
%imshow(borda);
[H,theta, rho]  = hough(borda);
Hui = H;
Hui /= max(H(:));
%figure;
%imshow(Hui);

Hl = H;
lim = 23; %lim = 55
Hl(Hl <= lim) = 0;
Hl(Hl > lim) = 255;
Hl = uint8(Hl);
%figure;
%imshow(Hl);

k = 1;
for i=1:size(Hl)(1)
  for j=1:size(Hl)(2)
    if Hl(i,j) == 255
      reta(k).rho = rho(i);
      reta(k).theta = theta(j);
      k = k + 1;
    end
  end
end

retaTrac = uint8(zeros(xMax,yMax));
numReta = size(reta)(2);
for k=1:numReta
  if reta(k).theta != 0
    ang = deg2rad(reta(k).theta);
    for x=1:xMax
      y = round((reta(k).rho - (x*cos(ang)) ) / sin(ang));
      if (y >= 1) && (y <= yMax)
        retaTrac(x,y) = 255;
      end
    end
  else
    ang = deg2rad(reta(k).theta);
    for y=1:yMax
      x = round((reta(k).rho - (y*sin(ang)) ) / cos(ang));
      if (x >= 1) && (x <= xMax)
        retaTrac(x,y) = 255;
      end
    end
  end
end

%figure;
%imshow(retaTrac);
imSeg = uint8(zeros(xMax,yMax));
raioViz = 1;
contList = 0;
for k=1:numReta
  segRet = false;
  xAnt = 0;
  yAnt = 0;
  if reta(k).theta != 0
    ang = deg2rad(reta(k).theta);
    for x=1:xMax
      yAnt = y;
      y = round((reta(k).rho - (x*cos(ang)) ) / sin(ang));
      if (y >= 1) && (y <= yMax)
        if bordaViz(borda, x, y, raioViz) && segRet == false
          segRet = true;
          contList = contList + 1;
          listaSeg(contList).ini.x = x;
          listaSeg(contList).ini.y = y;
        else
          if bordaViz(borda, x, y, raioViz) && segRet == true
            imSeg(x,y) = 255;
          else
            if !bordaViz(borda, x, y, raioViz) && segRet == true
              segRet = false;
              listaSeg(contList).fim.x = x-1;
              listaSeg(contList).fim.y = yAnt;
            end
          end
        end
      else
        if segRet == true
          segRet = false;
          listaSeg(contList).fim.x = x-1;
          listaSeg(contList).fim.y = yAnt;
        end
      end
    end
  else
    ang = deg2rad(reta(k).theta);
    for y=1:yMax
      xAnt = x;
      x = round((reta(k).rho - (y*sin(ang)) ) / cos(ang));
      if (x >= 1) && (x <= xMax)
        if bordaViz(borda, x, y, raioViz) && segRet == false
          segRet = true;
          contList = contList + 1;
          listaSeg(contList).ini.x = x;
          listaSeg(contList).ini.y = y;
        else
          if bordaViz(borda, x, y, raioViz) && segRet == true
            imSeg(x,y) = 255;
          else
            if !bordaViz(borda, x, y, raioViz) && segRet == true
              segRet = false;
              listaSeg(contList).fim.x = xAnt;
              listaSeg(contList).fim.y = y-1;
            end
          end
        end
      else
        if segRet == true
          segRet = false;
          listaSeg(contList).fim.x = xAnt;
          listaSeg(contList).fim.y = y-1;
        end
      end
    end
  end
end

for i=1:size(listaSeg)(2)
  fprintf("i = (%d,%d) f = (%d,%d)\n", listaSeg(i).ini.x, listaSeg(i).ini.y, listaSeg(i).fim.x, listaSeg(i).fim.y);
end

figure;
imshow(imSeg);
