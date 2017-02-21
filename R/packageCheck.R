if(!file.exists('./R/.pkgSuccess'))
{
	chooseCRANmirror(ind=1)
	print('Checking to see if you have all the required R packages...')
	primaryPkgs <- c("WGCNA","tcltk","gdata","png","ggmap")
	deps = unlist(tools::package_dependencies(c("WGCNA","tcltk","gdata","png","ggmap"),recursive=T,db=available.packages()))
	deps = c(deps,primaryPkgs)
	inst = installed.packages()
	toInstall = deps[!deps%in%inst[,1]]
	
	if(length(toInstall)>0)
	{
		print('Installing missing R packages. Please wait. You should only have to do this once.')
		for(pkg in toInstall)
		{
			#print(pkg)
			source("https://bioconductor.org/biocLite.R")
			if(.Platform$OS.type=="windows" & file.access(.libPaths()[length(.libPaths())], mode=2)==-1) #R library not writable in Windows, will make custom library and install packages there
			{
                if(!file.exists("./.libraries"))
                {
                    system('mkdir ./.libraries')
                    system('attrib +h ".libraries"')
                }
				res = try(install.packages(pkg,lib="./.libraries"))
				if(class(res)=="try-error")
				{
					res2 = biocLite(pkg,lib="./.libraries")
				
					if (class(res2)=="try-error")
					{
						errs = 1
						stop(paste('Unable to install R package', pkg,". Please try to troubleshoot this yourself."))
					}
				}
			}else{
				res = try(install.packages(pkg))
				if(class(res)=="try-error")
				{
					res2 = biocLite(pkg)
				
					if (class(res2)=="try-error")
					{
						errs = 1
						stop(paste('Unable to install R package', pkg,". Please try to troubleshoot this yourself."))
					}
				}

			}
		}
	}else{
		print('All packages found. Proceeding.')
	}
	
	if(!exists("errs"))
	{
		system(paste("touch","./R/.pkgSuccess"))
		system(paste("attrib +h ./R/.pkgsuccess"))
	}
}

