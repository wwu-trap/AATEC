%----------------------------------------------------------------------
%                       Coloring of Stimuli
%----------------------------------------------------------------------

function    rgbImage = coloring_fucntion(image, color)

grey = evalin('base', 'grey');

img_tmp = image;
img_tmp(img_tmp<240)=0; img_tmp(img_tmp~=0)=255;

rgbImage = cat(3, img_tmp, img_tmp, img_tmp);


[rows, columns, ~] = size(rgbImage);

for ii=1:rows
    for jj=1:columns
        if rgbImage(ii,jj,1) == 0
            rgbImage(ii,jj,:) = color*255;

        elseif rgbImage(ii,jj,1) == 255
            rgbImage(ii,jj,:) = 255*[grey,grey,grey];

        end
    end
end

end
