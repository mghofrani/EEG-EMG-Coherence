function age = returnAge(caseName,numeric,text)    
    idx = strfind(text, caseName);
    age = numeric(~cellfun(@isempty,idx));
end