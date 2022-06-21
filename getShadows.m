function shadows = getShadows(facets,vert,fn,sunDir) %#codegen
% facets: obj_patch.Faces
% vert: obj_patch.Vertices
% fn: faceNormals (from calculateFaceNormals.m)
% sunDir: [x y z] , [1 0 0] 

% number of facets
numFacets = length(facets);

% initialize output
shadows = zeros(numFacets,1);

% first compute the facets that are facing towards the sun
isLit = dot(fn,repmat(sunDir,1,numFacets)',2)>0;
idxSunFacing = find(isLit);

for kk = 1:length(idxSunFacing)
    ii = idxSunFacing(kk);

    % get indices of this facet
    thisFacet = facets(ii,:);

    % get vertices associated with this facet
    vert_thisFacet = vert(thisFacet,:);
    
    % get facet normal for this facet
    fn_thisFacet = fn(ii,:)';

    % check if there is an intersection any other facet in the sun direction
    idx = idxSunFacing;
    for nn = 1:length(idx)% loop through other facets
        jj = idx(nn);
        % if candidate index equals reference facet, then skip iteration
        if ii == jj
            continue
        end

        % get indices of candidate facet
        canFacet = facets(jj,:);
        
        % vertices for candidate facet
        vert_canFacet = vert(canFacet,:);

        % facet normals for this candidate facet
        fn_canFacet = fn(jj,:)';

        [isLit(ii)] = lineTriPatchIntersection( vert_thisFacet, sunDir, vert_canFacet, fn_canFacet );
        
        % if the intersection is found, stop checking against the rest of
        % the facets
        if isLit(ii) == false
            break
        end
    end
    
    % if the facet is still found to be lit (no self-shadowing), then
    % compute angle b/w facet normal and sun direction
    shadows(ii) = dot(fn_thisFacet,sunDir);

end