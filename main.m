clear;
clc;

pkg load image;

xMax = uint8(size(quad)(1));
yMax = uint8(size(quad)(2));
quad = uint8(zeros(xMax,yMax));

for x=21:80
  for y=21:80
    quad(x,y) = 255;
  end
end

%figure;
%imshow(quad);
bordaQuad = edge(quad, 'canny'); %bordaQuad = edge(quad, 'sobel');
figure;
imshow(bordaQuad);
[H,theta, rho]  = hough(bordaQuad);
Hui = H;
Hui /= max(H(:));
figure;
imshow(Hui);

Hl = H;
lim = 55; %lim = 80
Hl(Hl <= lim) = 0;
Hl(Hl > lim) = 255;
Hl = uint8(Hl);
Hb = Hl;
Hb(Hb < 255) = 0;
Hb(Hb == 255) = 1;
count = 0;
for i=1:size(Hl)(1)
  for j=1:size(Hl)(2)
    if Hl(i,j) == 255
      count = count + 1;
    end
  end
end
disp(count);
figure;
imshow(Hl);

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
    for x=1:xMax
      ang = deg2rad(reta(k).theta);
      y = round((reta(k).rho - (x*cos(ang)) ) / sin(ang));
      if (y >= 1) && (y <= yMax)
        retaTrac(x,y) = 255;
      end
    end
  else
    for y=1:yMax
      ang = deg2rad(reta(k).theta);
      x = round((reta(k).rho - (y*sin(ang)) ) / cos(ang));
      if (x >= 1) && (x <= xMax)
        retaTrac(x,y) = 255;
      end
    end
  end
end

figure;
imshow(retaTrac);
imSeg = uint8(zeros(xMax,yMax));
contList = 0;
borda = bordaQuad;
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
        if bordaViz(borda, x, y, 1) && segRet == false
          segRet = true;
          contList = contList + 1;
          listaSeg(contList).ini.x = x;
          listaSeg(contList).ini.y = y;
        else
          if bordaViz(borda, x, y, 1) && segRet == true
            imSeg(x,y) = 255;
          else
            if !bordaViz(borda, x, y, 1) && segRet == true
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
        if bordaViz(borda, x, y, 1) && segRet == false
          segRet = true;
          contList = contList + 1;
          listaSeg(contList).ini.x = x;
          listaSeg(contList).ini.y = y;
        else
          if bordaViz(borda, x, y, 1) && segRet == true
            imSeg(x,y) = 255;
          else
            if !bordaViz(borda, x, y, 1) && segRet == true
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
