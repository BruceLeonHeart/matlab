xDoc = xmlread('demo_prescan.xml');
childNodes = getChildNodes(xDoc);
numChildNodes = getLength(childNodes);
for count = 1:numChildNodes
    theChild = item(childNodes,count-1);
end

function [text,name,attr,childs,textflag] = getNodeData(theNode)
    name = toCharArray(getNodeName(theNode))';
    name = strrep(name, '-', '_dash_');
    name = strrep(name, ':', '_colon_');
    name = strrep(name, '.', '_dot_');
    
    attr = parseAttributes(theNode);
    if (isempty(fieldnames(attr))) 
        attr = []; 
    end
    
    [childs,text,textflag] = parseChildNodes(theNode);
    
    if (isempty(fieldnames(childs)) && isempty(fieldnames(text)))
        text.(textflag) = toCharArray(getTextContent(theNode))';
    end
    
end

function attributes = parseAttributes(theNode)
    attributes = struct;
    if hasAttributes(theNode)
       theAttributes = getAttributes(theNode);
       numAttributes = getLength(theAttributes);

       for count = 1:numAttributes
            str = toCharArray(toString(item(theAttributes,count-1)))';
            k = strfind(str,'='); 
            attr_name = str(1:(k(1)-1));
            attr_name = strrep(attr_name, '-', '_dash_');
            attr_name = strrep(attr_name, ':', '_colon_');
            attr_name = strrep(attr_name, '.', '_dot_');
            attributes.(attr_name) = str((k(1)+2):(end-1));
       end
    end
end