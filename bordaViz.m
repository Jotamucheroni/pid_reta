function segmento = bordaViz(imagem, x, y, raioViz)
   segmento = false;
   
   for i=(-raioViz):raioViz
     for j=(-raioViz):raioViz
       if x+i >= 1 && x+i <= size(imagem)(1) && y+j >= 1 && y+j <= size(imagem)(2)
         if imagem(x+i,y+j) == 1
            segmento = true;
            break;
         end
       end
       if segmento == true
         break;
       end
     end
   end
   
end
