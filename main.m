% Limpa a tela e as variáveis da memória
clear all;
clc all;

% Carrega o pacote com funções para manipulação de imagens
pkg load image;

% Parâmetros do algoritmo
Im.name = 'borracha.jpg'; % porta.png ou borracha.jpg
Im.filtro = 'sobel'; % canny - quadrado, sobel - outros 
Im.taxaL = 0.26; % 0.9 - quadrado, 0.35 - porta, 0.26 - borracha
Im.raioViz = 0; % 0 - borracha, 1 - outros
Im.limiarBorda = 0.5; % 0.5 - borracha, 0.68 - porta 
Im.limiarSeg = 5; % borracha - 5, porta - 80
Im.limiarParal = 10; %  borracha - 10, porta - 58

% Carrega a imagem e converte para tons de cinza
I = rgb2gray(imread(Im.name));

% Gera uma imagem de tamanho 100x100 com um quadrado de lado 60 no centro 
%I = uint8(zeros(100,100));
%I(21:80, 21:80) = 255;

xMax = uint8(size(I)(1));
yMax = uint8(size(I)(2));
figure;
imshow(I);

% Detecta as bordas da imagem
%borda = edge(I, Im.filtro);
borda = sobel(I);
figure;
imshow(borda);

% Binariza a imagem de bordas
borda(borda <= Im.limiarBorda) = 0;
borda(borda > Im.limiarBorda) = 1;
figure;
imshow(borda);

% Calcula a transformada de Hough
[H, theta, rho]  = TH(borda);
Hui = H;
Hui /= max(H(:));
figure;
imshow(Hui);

% Binariza a transformada de Hough
Hl = H;
lim = Im.taxaL*(max(Hl(:)));
Hl(Hl <= lim) = 0;
Hl(Hl > lim) = 255;
Hl = uint8(Hl);
figure;
imshow(Hl);

% Determina os coeficientes das equações da reta determinadas pela tranformada de Hough
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

% Gera uma imagem com as retas encontradas
retaTrac = uint8(zeros(xMax,yMax));
numReta = size(reta)(2);
for k=1:numReta
  if reta(k).theta != 0 && reta(k).theta != 180
    ang = deg2rad(reta(k).theta);
    for x=1:xMax
      y = round((reta(k).rho - (x*cos(ang)) ) / sin(ang));
      if (y >= 1) && (y <= yMax)
        retaTrac(x,y) = 255;
      end
    end
  end
  if reta(k).theta != 90 && reta(k).theta != -90
    ang = deg2rad(reta(k).theta);
    for y=1:yMax
      x = round((reta(k).rho - (y*sin(ang)) ) / cos(ang));
      if (x >= 1) && (x <= xMax)
        retaTrac(x,y) = 255;
      end
    end
  end
end
figure;
imshow(retaTrac);

% Determina os seguimentos de reta a partir das retas guia
imSeg = uint8(zeros(xMax,yMax));
raioViz = Im.raioViz;
contList = 0;
for k=1:numReta
  segRet = false;
  xAnt = 0;
  yAnt = 0;
  if reta(k).theta != 0 && reta(k).theta != 180
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
          listaSeg(contList).aceito = false;
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
    if segRet == true
        segRet = false;
        listaSeg(contList).fim.x = x;
        listaSeg(contList).fim.y = y;
    end
  end
  if reta(k).theta != 90 && reta(k).theta != -90
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
          listaSeg(contList).aceito = false;
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
    if segRet == true
        segRet = false;
        listaSeg(contList).fim.x = x;
        listaSeg(contList).fim.y = y;
    end
  end
end
figure;
imshow(imSeg);

% Remove segmentos muito pequenos
contAceito = 0;
for i=1:size(listaSeg)(2)
  %Distancia chessboard
  if max([abs(listaSeg(i).ini.x - listaSeg(i).fim.x) abs(listaSeg(i).ini.y - listaSeg(i).fim.y)]) > Im.limiarSeg
    listaSeg(i).aceito = true;
  end
end

% Remove segmentos semelhantes
for i=1:size(listaSeg)(2)
    for j=1:size(listaSeg)(2)
      if listaSeg(j).aceito && j != i && abs(listaSeg(i).ini.x - listaSeg(j).ini.x) < Im.limiarParal && abs(listaSeg(i).ini.y - listaSeg(j).ini.y) < Im.limiarParal && abs(listaSeg(i).fim.x - listaSeg(j).fim.x) < Im.limiarParal && abs(listaSeg(i).fim.y - listaSeg(j).fim.y) < Im.limiarParal
        listaSeg(i).aceito = false;
        break;
      end
    end
  if listaSeg(i).aceito
    contAceito++;
    fprintf("%d: i = (%d,%d) f = (%d,%d)\n", contAceito, listaSeg(i).ini.x, listaSeg(i).ini.y, listaSeg(i).fim.x, listaSeg(i).fim.y);
  end
end

% Gera imagem com segmentos de reta após filtragem 
imSeg = uint8(zeros(xMax,yMax));
contList = 0;
for k=1:numReta
  segRet = false;
  xAnt = 0;
  yAnt = 0;
  if reta(k).theta != 0 && reta(k).theta != 180
    ang = deg2rad(reta(k).theta);
    for x=1:xMax
      yAnt = y;
      y = round((reta(k).rho - (x*cos(ang)) ) / sin(ang));
      if (y >= 1) && (y <= yMax)
        if bordaViz(borda, x, y, raioViz) && segRet == false
          segRet = true;
          contList = contList + 1;
        else
          if bordaViz(borda, x, y, raioViz) && segRet == true && listaSeg(contList).aceito
            imSeg(x,y) = 255;
          else
            if !bordaViz(borda, x, y, raioViz) && segRet == true
              segRet = false;
            end
          end
        end
      else
        if segRet == true
          segRet = false;
        end
      end
    end
    if segRet == true
      segRet = false;
    end
  end
  if reta(k).theta != 90 && reta(k).theta != -90
    ang = deg2rad(reta(k).theta);
    for y=1:yMax
      xAnt = x;
      x = round((reta(k).rho - (y*sin(ang)) ) / cos(ang));
      if (x >= 1) && (x <= xMax)
        if bordaViz(borda, x, y, raioViz) && segRet == false
          segRet = true;
          contList = contList + 1;
        else
          if bordaViz(borda, x, y, raioViz) && segRet == true && listaSeg(contList).aceito
            imSeg(x,y) = 255;
          else
            if !bordaViz(borda, x, y, raioViz) && segRet == true
              segRet = false;
            end
          end
        end
      else
        if segRet == true
          segRet = false;
        end
      end
    end
    if segRet == true
        segRet = false;
    end
  end
end
figure;
imshow(imSeg);
