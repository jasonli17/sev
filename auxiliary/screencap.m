function screencap(graphic_h,img_fmt,img_pathname,img_filename)
% screencap(graphic_h,img_fmt,img_pathname,img_filename)
%  graphic_h may be a figure or axes handle
%  img_fmt can be any format available to matlab's print function (help
%  print)
% pathname and filename can be included for the stored image are optional;
% the function will request from the user if not provided
%
% side effect:  The file 'screenshotpath.mat' will be stored in the current
% directory of this function to retain the location of the image pathname
% used last.

% author: Hyatt Moore, IV (< June, 2013)


if(ishandle(graphic_h))
    p = mfilename('fullpath');
    
    screenpathfile = fullfile(fileparts(p),'screenshotpath.mat');
        
    if(nargin<2 || isempty(img_fmt))
       img_fmt=''; %default to a jpeg
    else
        %tack on the -d prefix, but first remove any occurrence of it and
        %of any leading periods
        img_fmt = strcat('-d',strrep(strrep(img_fmt,'.',''),'-d',''));
        
    end
    if(nargin<3)
        if(exist(screenpathfile,'file'))
            m = load(screenpathfile);
            img_pathname = m.img_pathname;
        else
            img_pathname = pwd;
        end
    end
    if(nargin<4)
        [opt,device, extension, clas, colorDevs,dest, descr, clips] = printtables;
        toss = false(size(extension));
        for f=1:numel(descr)
            ext = extension{f};
            
            if(strcmpi(ext,'jet')||strcmpi(ext,'ep')||strcmpi(ext,'ibm')||strcmpi(ext,'jet'))
                toss(f) = true;
            end
            if(isempty(extension{f}))
                extension{f} = 'm';
            end
            if(isempty(descr{f}))
                
                descr{f} = device{f};
            end
        end
        filterspec = [strcat('*.',extension(~toss)),strcat(descr(~toss),' (*.',extension(~toss),')')];
        
        device = device(~toss);
%         img_filename = strcat('screenshot',datestr(now,'ddmmmyyyy HH:MM:SS'),'.',strrep(img_fmt,'.',''));
        img_filename = 'screenshot';
        [img_filename, img_pathname, filterindex] = uiputfile(filterspec,'Screenshot name',fullfile(img_pathname,img_filename));
        if(filterindex)
            img_fmt = strcat('-d',device{filterindex});
        end
    end
    
    if isequal(img_filename,0) || isequal(img_pathname,0)
        disp('User cancelled')
    else
        save(screenpathfile,'img_pathname');

        try
            graphic_type = get(graphic_h,'type');
            if(strcmpi(graphic_type,'figure'))
%                 f = copyobj(graphic_h,get(graphic_h,'parent'));
                f = graphic_h;
%                                 f = figure('visible','off','paperpositionmode','auto',...
%                     'units',get(fig_h,'units'),'position',get(fig_h,'position'),...
%                     'toolbar','none','menubar','none','units','normalized');

            else
                fig_h = get(graphic_h,'parent');               
                f = figure('visible','off',...
                    'units',get(fig_h,'units'),'position',get(fig_h,'position'),...
                    'toolbar','none','menubar','none','units','normalized');
                axes_copy = copyobj(graphic_h,fig_h);
                if(strcmpi(graphic_type,'axes'))
                    set(axes_copy,'parent',f);
                    cropFigure2Axes(f,axes_copy); %- don't like this for the
                    set(axes_copy,'position',[0.05    0.0500    0.925    0.90]);
                elseif(strcmpi(graphic_type,'uipanel'))
                    coord = getScreenCoordinates(graphic_h);
                    
                    set(f,'units','pixels')
                    set(f,'position',coord);
                    set(axes_copy,'units','normalized','position',[0.0 0.0, 1 1],'bordertype','none');
                    set(axes_copy,'parent',f);
                    child_axes = findobj(graphic_h,'type','axes');
                    if(~isempty(child_axes))
                        axes_child_positions = get(child_axes,'position');                        
                        axes_copy_children_handles = findobj(axes_copy,'type','axes');
                        if(~iscell(axes_child_positions))
                            axes_child_positions = {axes_child_positions};
                        end
                        for k=1:numel(axes_copy_children_handles)
                            set(axes_copy_children_handles(k),'position',axes_child_positions{k});
                        end
                    end



                end
            end

            set(f,'visible','on');
            set(f,'clipping','off','paperpositionmode','auto','inverthardcopy','on');
            set(f,'clipping','on','paperpositionmode','auto','inverthardcopy','on');

            %         style = getappdata(f,'Exportsetup');
            %         if isempty(style)
            %             try
            %                 style = hgexport('readstyle','Default');
            %             catch me
            %                 style = hgexport('factorystyle');
            %             end
            %         end
            %         hgexport(f,fullfile(img_pathname,img_filename),style,'Format',filterspec{filterindex,1});
            disp(img_fmt);
            disp(img_filename);
            print(f,img_fmt,'-r300',fullfile(img_pathname,img_filename),'-opengl');
            
            %save the screenshot
            %         print(f,['-d',filterspec{filterindex,1}],'-r75',fullfile(img_pathname,img_filename));
            %         print(f,fullfile(img_pathname,img_filename),['-d',filterspec{filterindex,1}]);
            %         print(f,['-d',filterspec{filterindex,1}],fullfile(img_pathname,img_filename));
            %         set(handles.axes1,'position',apos,'dataaspectratiomode','manual' ,'dataaspectratio',dataaspectratio,'parent',handles.sev_main_fig)
            
            if(~isequal(f,graphic_h))  %don't delete original figures...
                delete(f);
            end
            
        catch ME
            showME(ME);
            delete(f);
        end
    end
end
end