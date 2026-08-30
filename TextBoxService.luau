--[[
	@Author: Private3110
	@Created: 12/13/2025
	@Last Updated: 8/30/2026
	@Description: 
		Provides helper utilities to make Roblox TextBox objects more powerful and 
		easier to work with, especially when dealing with multi-line text.
]]

const TextService = game:GetService("TextService");

const createTextBoundsParameters = require("@self/Utilites/createTextBoundsParameters");

const CURSOR_POSITION_ERROR_MESSAGE = "TextBox is not focused.";

local TextBoxService = {};

--[[
	Returns an array of strings split by newline characters.
	
	<strong>textBox:</strong> A reference to a TextBox object.
]]
function TextBoxService.GetLineBreaks(textBox: TextBox) : {string}
	local lines = string.split(textBox.Text, "\n");
	return lines;
end

--[[
	Returns the string of the referenced line.
	
	<strong>textBox:</strong> A reference to a TextBox object.
	<strong>lineIndex:</strong> the specified line.
]]
function TextBoxService.GetTextOfLine(textBox: TextBox, lineIndex: number) : string
	local lines = TextBoxService.GetLineBreaks(textBox);
	local textOfLine = lines[lineIndex];
	return textOfLine;
end

--[=[
	Returns the substring from the start of the current line to your cursor position.
	
	<strong>textBox:</strong> A reference to a TextBox object.
```
	--[[
		Note: Imagine the text inside the referenced text box is "Hello World!" and the cursor position is 5.
	]]

	--// Modules
	local TextBoxService = require("@self/TextBoxService")
	
	--// Variables
	local textBox = script.Parent.TextBox
	
	--// Get substring from current line to cursor position
	local sub = TextBoxService:GetCurrentLineTextUpToCursor(textbox)
	print(sub) -- output: Hello
```
]=]
function TextBoxService.GetCurrentLineTextUpToCursor(textBox: TextBox) : string
	local cursorPosition = textBox.CursorPosition;
	assert(cursorPosition ~= -1, CURSOR_POSITION_ERROR_MESSAGE); -- Checks if the textbox is focused.
	
	local lines = TextBoxService.GetLineBreaks(textBox);
	local lineText, currentLine = TextBoxService.GetCurrentLine(textBox);
	
	local startIndex = 1;
	if currentLine > 1 then
		for index = 1, currentLine - 1 do
			startIndex += #lines[index] + 1;
		end 
	end
	
	local lineCursorSubstring = string.sub(
		textBox.Text, 
		startIndex, 
		cursorPosition - 1
	);
	
	return lineCursorSubstring;
end

--[[
	Calculates the width and height of text from start to cursor position.
	
	<strong>textBox:</strong> A reference to a TextBox object.
]]
function TextBoxService.GetTextBoundsToCursorAsync(textBox: TextBox) : Vector2
	local cursorPosition = textBox.CursorPosition;
	assert(cursorPosition ~= -1, CURSOR_POSITION_ERROR_MESSAGE);
	
	local lineCursorSubstring = TextBoxService.GetCurrentLineTextUpToCursor(textBox);
	print(lineCursorSubstring)
	
	local _, lineIndex = TextBoxService.GetCurrentLine(textBox);
	local singleLineHeight = textBox.TextSize * textBox.LineHeight;
	local textBoundsHeight = textBox.TextSize + (lineIndex - 1) * singleLineHeight;
	
	local textBoundsParams = createTextBoundsParameters(textBox, lineCursorSubstring);
	local textBoundsWidth = TextService:GetTextBoundsAsync(textBoundsParams).X;
	
	local textBounds = Vector2.new(textBoundsWidth, textBoundsHeight);
	return textBounds;
end

--[[
	Calculates the width and height of text from start to end of the specified line.
	
	<strong>textBox:</strong> A reference to a TextBox object.
	<strong>lineIndex:</strong> the specified line.
]]
function TextBoxService.GetTextBoundsOfLineAsync(textBox: TextBox, lineIndex: number) : Vector2
	if (not lineIndex) then 
		return Vector2.zero
	end
	
	local lines = TextBoxService.GetLineBreaks(textBox);
	local lineText = lines[lineIndex];
	
	local textBoundsParams = createTextBoundsParameters(textBox, lineText);
	return TextService:GetTextBoundsAsync(textBoundsParams);
end

--[[
	Returns the <code>Vector2</code> position (relative to the top-left of the text) 
	where a specific line starts.
	
	<strong>textBox:</strong> A reference to a TextBox object.
	<strong>lineIndex:</strong> The line number to find the position of.
]]
function TextBoxService.GetPositionOfLine(textBox: TextBox, lineIndex: number): Vector2
	if (not lineIndex or lineIndex < 1) then lineIndex = 1; end
	
	local singleLineHeight = textBox.TextSize * textBox.LineHeight;
	
	local yOffset = (lineIndex - 1) * singleLineHeight;
	
	return Vector2.new(0, yOffset);
end

--[[
    Determines which line the cursor is currently on and returns that line's
    content along with its index.
    
    <strong>textBox:</strong> A reference to a TextBox object.
]]
function TextBoxService.GetCurrentLine(textBox: TextBox) : (string, number)
	local cursorPosition = textBox.CursorPosition;
	assert(cursorPosition ~= -1, CURSOR_POSITION_ERROR_MESSAGE);
	
	local lines = TextBoxService.GetLineBreaks(textBox);
	
	local subToCursorPosition = 0;
	for index, lineText in ipairs(lines) do
		subToCursorPosition += #lineText + 1;
		if (subToCursorPosition >= cursorPosition) then
			return lineText, index;
		end
	end
end

return TextBoxService;
