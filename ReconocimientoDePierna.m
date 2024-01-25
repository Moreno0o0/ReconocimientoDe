
%procesamiento de imagenes 

%Reconocimiento del movimiento de la pierna al caminar

%Hecho por:
%Moreno Lemus Juan Diego

%Este programa realiza un reconocimiento la pierna a travez de 
%circulos de colores los cuales estan delimitados por 3 colores y 3 distintas reginones
%el programa esta configurado para el video especificado, para sustituirlo
%por otro se debe modificar los parametros de los colores y los parametros
%de las regiones

close all
clear untitled

%Region 1
x11 = 900;x12 = 1100;
y11 = 400;y12 = 500;

%Region 2
x21 = 800;x22 = 1050;
y21 = 600;y22 = 700;

%Region 3
x31 = 700;x32 = 1300;
y31 = 700;y32 = 900;

%Rango de colores
% rojo_min ,rojo_max ,verde_min ,verde_max ,azul_min ,azul_max ;
color1_rango = [150, 255, 70, 110, 110, 140];
color2_rango = [0, 40, 70, 255, 70, 190];
color3_rango = [0, 90, 80, 220, 150, 255];

coordenadas = [x11, x12, y11, y12, ...
                x21, x22, y21, y22, ...
                x31, x32, y31, y32, ...
                color1_rango, color2_rango, color3_rango];

f1 = figure('Name','Reconocimiento de movimiento: Video ',NumberTitle='off');
f1.Position(1:4)=[50 100 1400 650];



video = VideoReader('video2_rectificado.mp4');


radio = round(36.6/2); %radio aporoximado de los circulos 

ncuadros  = 100;%frame aproximado hasta donde termina el primer paso


angulo_rodilla(ncuadros-50)=0;
angulo_cadera(ncuadros-50)=0;

%programa principal 
a=0;
for tiempo = 50: ncuadros
    a = a+1;
    frame = read(video, tiempo);
    frame2 = extrae_imagen(frame,coordenadas);

    figure(f1);
   
    imshow (frame);
    %imshow (frame2);%mostrar imagen2 (b&n) 
    [centro1 ,centro2, centro3] = centroides(frame2,coordenadas);
    
    viscircles([centro1(1),centro1(2)],radio,Color='g');
    viscircles([centro2(1),centro2(2)],radio,Color='g');
    viscircles([centro3(1),centro3(2)],radio,Color='g');

    line([centro1(1), centro2(1)], [centro1(2), centro2(2)] , 'Color', 'g', 'LineWidth', 3);
    line([centro2(1), centro3(1)], [centro2(2), centro3(2)], 'Color', 'g', 'LineWidth', 3);
    
    axis('equal');
        
    [angulo_cadera(a),angulo_rodilla(a)] = calcula_angulo(centro1,centro2,centro3);
     
end


f2 = figure('Name','Reconocimiento de movimiento: Graficas ',NumberTitle='off');
f2.Position(1:4)=[50 100 1400 650];
figure(f2)
axis="equal";
subplot(1,2,1);plot(linspace(0,100,51),angulo_cadera,LineStyle="-" ,Marker="*");title('Cadera');
subplot(1,2,2);plot(linspace(0,100,51),angulo_rodilla,LineStyle="-" ,Marker="*");title('Rodilla');


%funcion auxiliar
%verifica si existe el color especificado en las regiones dadas y las marca
%en blanco en frame2 
function frame2 = extrae_imagen(frame,coordenadas) 

    frame2 = double(zeros(size(frame,1), size(frame,2)))/255;
    %circulo 1
    x = [coordenadas(1), coordenadas(2), coordenadas(5), coordenadas(6), coordenadas(9), coordenadas(10)];
    y = [coordenadas(3), coordenadas(4), coordenadas(7), coordenadas(8), coordenadas(11), coordenadas(12)];
    
    %colores de los circulos 
    c1 = coordenadas(13:18);
    c2 = coordenadas(19:24);
    c3 = coordenadas(25:30);
    [X, Y] = meshgrid(1:size(frame, 2), 1:size(frame, 1));
    
    % Circulo rojo 1
    indices_c1 = X >= x(1) & X <= x(2) & Y >= y(1) & Y <= y(2);
    condicion_c1 = frame(:, :, 1) >= c1(1) & frame(:, :, 1) <= c1(2) ...
                & frame(:, :, 2) >= c1(3) & frame(:, :, 2) <= c1(4) ...
                & frame(:, :, 3) >= c1(5) & frame(:, :, 3) <= c1(6);
    frame2(indices_c1 & condicion_c1) = 1;
    % Circulo verde 2
    indices_c2 = X >= x(3) & X <= x(4) & Y >= y(3) & Y <= y(4);
    condicion_c2 = frame(:, :, 1) >= c2(1) & frame(:, :, 1) <= c2(2) ...
                & frame(:, :, 2) >= c2(3) & frame(:, :, 2) <= c2(4) ...
                & frame(:, :, 3) >= c2(5) & frame(:, :, 3) <= c2(6);
    frame2(indices_c2 & condicion_c2) = 1;

    % Circulo azul 3
    indices_c3 = X >= x(5) & X <= x(6) & Y >= y(5) & Y <= y(6);
    condicion_c3 = frame(:, :, 1) >= c3(1) & frame(:, :, 1) <= c3(2) ...
                & frame(:, :, 2) >= c3(3) & frame(:, :, 2) <= c3(4) ...
                & frame(:, :, 3) >= c3(5) & frame(:, :, 3) <= c3(6);
    frame2(indices_c3 & condicion_c3) = 1;
end

%funcion auxilar 
%recibe "frame 2" los obejetos resaltados en blanco y obtiene el centro de
%dichos objetos
function [centro1,centro2, centro3] = centroides(frame2, coordenadas)
    x = [coordenadas(1), coordenadas(2), coordenadas(5), coordenadas(6), coordenadas(9), coordenadas(10)];
    y = [coordenadas(3), coordenadas(4), coordenadas(7), coordenadas(8), coordenadas(11), coordenadas(12)];

    C1 = regionprops(frame2(y(1):y(2), x(1):x(2) ),'Centroid'); 
    centro1 = cat(1,C1.Centroid);
    centro1(1) = centro1(1) + x(1);%X
    centro1(2) = centro1(2) + y(1);%y
    
    
    C2 = regionprops(frame2(y(3):y(4), x(3):x(4) ),'Centroid');
    centro2 = cat(1,C2.Centroid);
    centro2(1) = centro2(1) + x(3);%x
    centro2(2) = centro2(2) + y(3);%y
    
    C3 = regionprops(frame2(y(5):y(6), x(5):x(6) ),'Centroid');
    centro3 = cat(1,C3.Centroid);
    centro3(1) = centro3(1) + x(5);%x
    centro3(2) = centro3(2) + y(5);%y
    
end

%funcion auxilar recibe los tres centros de los circulos y calcula el
%angulo entre ellos
function  [angulo1 , angulo2 ] = calcula_angulo(centro1,centro2,centro3)
    
    m1 = (centro2(2)-(centro1(2)))/(centro2(1)-(centro1(1)));
    angulo1 = atand(m1) ;
    if angulo1 <0
        angulo1 = angulo1+90;
    else
        angulo1 = angulo1-90;
    end

    m2 = (centro3(2)-(centro2(2)))/(centro3(1)-(centro2(1)));
    angulo2 = atand(m2);
    if angulo2 <0
        angulo2 = angulo2+90;
    else
        angulo2 = angulo2-90;
    end
    angulo2 = angulo1 - angulo2;
end
