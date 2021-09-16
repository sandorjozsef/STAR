using JavaCall

function setup_java_libraries()
   
    if JavaCall.isloaded() == false
        package_list = [pwd() * "/src/JavaCall/star1libs/android_parcelable.jar",
                        pwd() * "/src/JavaCall/star1libs/joda-time-1.6.2.jar",
                        pwd() * "/src/JavaCall/star1libs/STAR_library.jar"];
                        
    
        JavaCall.addClassPath(package_list[1]);
        JavaCall.addClassPath(package_list[2]);
        JavaCall.addClassPath(package_list[3]);
        JavaCall.init(["-Xmx512M", "-Djava.class.path=$(@__DIR__)" #=, "-verbose:jni", "-verbose:gc"=# ]);
    end
    
end