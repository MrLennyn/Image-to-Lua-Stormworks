
--Image to Lua converter by MrLenyn
--It works by drawing lines instead of pixels, outputs a script ready to use in Stormworks monitors, with good performance.

--Version: 0.10

transparency = false
zoom_var = false
pos_var = false

size_limit = 300

function click(rx,ry,w,h, x, y)
	if x >= rx and y >= ry and x <= rx+w and y <= ry+h then
		return true
	else
		return false
	end
end

function draw_button(x,y,w,h,text,state)
  --83, 219, 165
  love.graphics.setColor(45/255,110/255,110/255,1)
  love.graphics.rectangle("fill",x,y,w,h) --box
  
    love.graphics.setColor(25/255,90/255,90/255,1) -- checkbox color white
    love.graphics.rectangle("fill",x+7,y+8,10,10)
  
  if state then
    love.graphics.setColor(103/255,239/255,185/255,1) -- checkbox color
    love.graphics.rectangle("fill",x+7,y+8,10,10)
  end
  
  love.graphics.setColor(0,0,0,1) -- checkbox
  love.graphics.rectangle("line",x+7,y+8,10,10)
  
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(text, x + 23, y,0,0.5,0.5)

end

function love.load()
  
  print("---------------------------------------")
  print("<<Image to Lua converter by Mr Lenyn>>")
  print("---------------------------------------")
  print("Please drag and drop your .png to the window")
  print("Keep your images small (64x64) and under")
  print("And your color count too")
  print("Stormworks character limit is 4096")
  print(" ")
  print(" ")
  
  
  font = love.graphics.newFont("OpenSans-Regular.ttf",32)
  
  function love.filedropped(file)
    file:open("r")
    data = file:read()
    file:close()
    
    filedata = love.filesystem.newFileData(data, 'img', 'file')
    
    imagedata = love.image.newImageData(filedata)
    
    width, height = imagedata:getDimensions()
    
    if width < size_limit and height < size_limit then -- limiting file size
    
      pixel_table = {}
      
      ----------------------
      --awesome gama fix equation by XLjedi
      gama_fix = true
      g_factor = 1.21
      ----------------------
      
      color_count = 0
      color_table = {}
      color_final = {}
      
      rect_table = {}
      temp_table = {}
      
      zoom = 5
      -----------------------------------
      
      
      
      for y = 0, height-1 do
        for x = 0, width-1 do
        r,g,b,a = imagedata:getPixel(x,y)
        index = (x+y*width)
        i = index
        
        table.insert(pixel_table, {r,g,b,a,x,y})
        
        
        end
      end


      
      function dump(o) -- function to print table to console
       if type(o) == 'table' then
          local s = '{'
          for k,v in pairs(o) do
             if type(k) ~= 'number' then k = '"'..k..'"' end
             s = s .. '},'..'{' .. dump(v) .. ','
          end
          return s .. '}'
       else
          return tostring(o)
       end
      end
      
      startDraw = true
      
      --notes:
      --tables are being saved from 1 of course, so 0,0 is stored at pos 1 in table. 
      --pixel_table [1] = r, [2] = g, [3] = b, [4] = a, [5] = x, [6] = y
      
      if startDraw then -- constructing color table and color count
        
        for i = 1, #pixel_table do
            current_color = tostring("\"" .. pixel_table[i][1] * 255 .. "," .. pixel_table[i][2] * 255 .. "," .. pixel_table[i][3] * 255 .. "," .. pixel_table[i][4] * 255 .. "\"")
            
            if i > 1 then
            last_color = tostring("\"" .. pixel_table[i-1][1] * 255 .. "," .. pixel_table[i-1][2] * 255 .. "," .. pixel_table[i-1][3] * 255 .. "," .. pixel_table[i-1][4] * 255 .. "\"")
            end
            
            if current_color ~= last_color and pixel_table[i][4] ~= 0 then
              color_found = false
              
              for c = 1, #color_table do
                if current_color == color_table[c] then
                  color_found = true
                end
              end
              
              if not color_found then
                table.insert(color_table, current_color)
                table.insert(color_final, {pixel_table[i][1] * 255, pixel_table[i][2] * 255, pixel_table[i][3] * 255, pixel_table[i][4] * 255})
              end
            end
            color_count = #color_final
        end
        
        color_count_finished = true
      end
      
      --constructing rectangle table
      --table should look like: rect_table = {[1] = "r,g,b,a", rectX1, rectY1, rectX2, rectY2, ... )

      line_lenght = 1

      for i = 1, #color_table do -- constructing final table
        
        temp_table = {}
        
        for b = 1, #pixel_table do
          
          px = pixel_table[b][5]
          py = pixel_table[b][6]
          current_color = tostring("\"" .. pixel_table[b][1] * 255 .. "," .. pixel_table[b][2] * 255 .. "," .. pixel_table[b][3] * 255 .. "," .. pixel_table[b][4] * 255 .. "\"")
          
          if b < #pixel_table then
          next_color = tostring("\"" .. pixel_table[b+1][1] * 255 .. "," .. pixel_table[b+1][2] * 255 .. "," .. pixel_table[b+1][3] * 255 .. "," .. pixel_table[b+1][4] * 255 .. "\"")
          end
          
          
          if current_color == color_table[i] then
            if current_color == next_color and px < width - 1 then
              line_lenght = line_lenght + 1
            elseif line_lenght > 1 then
              table.insert(temp_table, px + 1 - line_lenght)
              table.insert(temp_table, py)
              table.insert(temp_table, line_lenght)
              line_lenght = 1
            else
              table.insert(temp_table, px)
              table.insert(temp_table, py)
              table.insert(temp_table, line_lenght)
              line_lenght = 1
            end
          end
        end
        
        if gama_fix then
          temp_table = math.floor(color_final[i][1]^g_factor/255^g_factor*color_final[i][1]) .. "," .. math.floor(color_final[i][2]^g_factor/255^g_factor*color_final[i][2]) .. "," .. math.floor(color_final[i][3]^g_factor/255^g_factor*color_final[i][3]) .. "," .. math.floor(color_final[i][4]^g_factor/255^g_factor*color_final[i][4]) .. "," .. table.concat(temp_table, ",")
        else
          temp_table = color_final[i][1] .. "," .. color_final[i][2] .. "," .. color_final[i][3] .. "," .. color_final[i][4] .. "," .. table.concat(temp_table, ",")
        end
        
        table.insert(rect_table, temp_table)
      end
      
    
    if not transparency then
      --setting background (color with the most pixels)
      longest_table = 0
      longest_table_index = 0
      for i = 1, #rect_table do
        if #rect_table[i] > longest_table then
          longest_table_index = i
          longest_table = #rect_table[i]
          back_color = color_final[i][1] .. "," .. color_final[i][2] .. "," .. color_final[i][3] .. "," .. color_final[i][4]
        end
      end
      
      table.remove(rect_table, longest_table_index)
      table.insert(rect_table, 1, back_color)
    end
    
      --final rect table looks like = {{backgroundrgb},{r,g,b,a,px,py,lenght,px2,py2,lenght2 ... }}
      
      final_rect_table = "{" .. string.sub(dump(rect_table),4) .. "}"
      
      
      
      ---------------------------------------------------------
      
      --Printing to console!
      print("--------------------")
      print("Copied to clipboard!")
      print("--------------------")
      --Result string!
      print("")
      print("")
      if zoom_var then
        print("zoom=1 ")
        z_text = "zoom=1 "
      else
        z_text = ""
      end
      if pos_var then
        print("x=0 ")
        print("y=0 ")
        p_text = "x=0 " .. "y=0 "
      else
        p_text = ""
      end
      print("s=screen ")
      print("p=" .. final_rect_table)
      print(" ")
      print("function onDraw() ")
      
      if not transparency then
        print("s.setColor(p[1][1],p[1][2],p[1][3],p[1][4]) ") -- background drawn
        print("s.drawClear() ")
        print("for i=2,#p do ")
        
        trans_text = "s.setColor(p[1][1],p[1][2],p[1][3],p[1][4]) " .. "s.drawClear() " .. "for i=2,#p do "
      else
        print("for i=1,#p do ") -- no background drawn
        trans_text = "for i=1,#p do "
      end
      
      print("s.setColor(p[i][1],p[i][2],p[i][3],p[i][4]) ")
      print("for w=5,#p[i],3 do ")
      
      --drawing code
      if zoom_var and not pos_var then -- zoom
        print("s.drawRectF(p[i][w]*zoom,p[i][w+1]*zoom,p[i][w+2]*zoom,1*zoom) ")
        drawn_text = "s.drawRectF(p[i][w]*zoom,p[i][w+1]*zoom,p[i][w+2]*zoom,1*zoom) "
      end
      if zoom_var and pos_var then --zoom and pos
        print("s.drawRectF(p[i][w]*zoom+x,p[i][w+1]*zoom+y,p[i][w+2]*zoom,1*zoom) ")
        drawn_text = "s.drawRectF(p[i][w]*zoom+x,p[i][w+1]*zoom+y,p[i][w+2]*zoom,1*zoom) "
      end
      if pos_var and not zoom_var then -- pos only
        print("s.drawRectF(p[i][w]*x,p[i][w+1]+y,p[i][w+2],1) ")
        drawn_text = "s.drawRectF(p[i][w]+x,p[i][w+1]+y,p[i][w+2],1) "
      end
      if not zoom_var and not pos_var then
        print("s.drawRectF(p[i][w],p[i][w+1],p[i][w+2],1) ")
        drawn_text = "s.drawRectF(p[i][w],p[i][w+1],p[i][w+2],1) "
      end
      print("end")
      print("end")
      print("end")
      
      --------------------------------------------------------
      
      
      
      
      
      --final string to copy to clipboard and save
      final_text = z_text .. p_text .. "s=screen " .. "p=" .. final_rect_table .. "function onDraw() " .. trans_text .. "s.setColor(p[i][1],p[i][2],p[i][3],p[i][4]) " .. "for w=5,#p[i],3 do " ..  drawn_text .. "end " .. "end " .. "end "
      
      --saving on appdata
      local success, message = love.filesystem.write('text.txt', final_text)
      if success then 
        print ("")
      end
      
      --copying to clipboard
      love.system.setClipboardText(final_text)
      
      
      copy_alpha = 1 -- for "copied to clipboad" text sign
      
    else
      print(">>>Image too big!<<<")
      
    end
  end

end

function love.mousepressed(x,y,button, istouch, presses)
  
  if click(50,50,230,25,x,y) then
    transparency = not transparency
  elseif click(50,80,230,25,x,y) then
    zoom_var = not zoom_var
  elseif click(50,110,230,25,x,y) then
    pos_var = not pos_var
  end
  
end

function love.keypressed(key, scancode, isrepeat)
   if key == "escape" then
      love.event.quit()
   end
   if key == "a" then
      zoom = zoom + 2
   end
   if key == "s" then
      zoom = zoom - 2
   end
end

function love.draw()
  s_width, s_height = love.graphics.getDimensions()
  love.graphics.setFont(font, 64)
  
  love.graphics.setBackgroundColor(38/255,74/255,74/255,1)
  
  --buttons
  draw_button(50,50,230,25,"Transparency (More code!)", transparency)
  draw_button(50,80,230,25,"Zoom Variable", zoom_var)
  draw_button(50,110,230,25,"Position Variable", pos_var)
  
  if not startDraw then
    love.graphics.print("DRAG AND DROP", s_width/2-120, s_height/2)
    love.graphics.print(".png files only", s_width/2-50, s_height/2+45,0,0.5,0.5)
  end
  
  if imagedata then
    if width > size_limit and height > size_limit then -- limiting file size
      love.graphics.setColor(0.8,0.1,0.1,1)
      love.graphics.print("IMAGE IS TOO BIG!", s_width/2-125, s_height/2-100)
    end
  end
  
  if startDraw then
    
    
    for i = 1, #pixel_table do
      love.graphics.setColor(pixel_table[i][1], pixel_table[i][2], pixel_table[i][3], pixel_table[i][4])
      love.graphics.rectangle("fill", pixel_table[i][5]*zoom+s_width/2-(width/2*zoom), pixel_table[i][6]*zoom+s_height/2-(height/2*zoom) + 40, zoom, zoom)
    end
    
    love.graphics.setColor(45/255,110/255,110/255,1) --info boxes
    if width > size_limit and height > size_limit then
      love.graphics.setColor(0.8,0.1,0.1,1)
    end
    love.graphics.rectangle("fill",300,50,230,25)
    love.graphics.setColor(45/255,110/255,110/255,1)
    love.graphics.rectangle("fill",300,80,230,25)
    if #final_text >= 4096 then
      love.graphics.setColor(0.8,0.1,0.1,1)
    end
    love.graphics.rectangle("fill",300,110,230,25)
    
    love.graphics.setColor(1,1,1,1)
    
    love.graphics.print("Size : " .. width .. "x" .. height, 310, 50,0,0.5,0.5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Color count : " .. color_count, 310, 80,0,0.5,0.5)
    love.graphics.print("Character count : " .. #final_text, 310, 110,0,0.5,0.5)
    
      copy_alpha = copy_alpha - 0.005
    if copy_alpha > 0 then
      
      love.graphics.setColor(1,1,1,copy_alpha)
      love.graphics.print("Copied to Clipboard", s_width/2-155, s_height/2+200,0)
    end
  end
  
end
