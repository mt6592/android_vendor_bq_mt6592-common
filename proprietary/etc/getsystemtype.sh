#!/system/bin/sh
#苏 勇 2013年07月24日19:39:36 
#用来辨识系统的硬件,甚至根据这个可以修改版本号,也可以调整hal的东西

#得到各种信息,并保存
#对版本进行处理,注意*不*要/最好*不*要用awk/tr/grep/cut等工具
#比如       cktversion=SLFQ-S0A_CKT_L26EN_100_130724120103
#处理后
#   cktversion_project=SLFQ
#       cktversion_softcode=S0A
#         cktversion_customName=CKT
#               cktversion_language=L26EN
#                          cktversion_ver=100
#                         cktversion_longtime=130724120103
#                        cktversion_shorttime=130724
#
#相关sensor的信息来自于
# "/sys/bus/platform/drivers/msensor/chipinfo"
# "/sys/bus/platform/drivers/gsensor/chipinfo"
# "/sys/bus/platform/drivers/als_ps/chipinfo"
# "/sys/bus/platform/drivers/gyroscope/chipinfo"
#相关lcd的信息来自于
# "/sys/devices/platform/mtkfb.0/lcm_name"
#相关摄像头的信息来自于
#./sys/devices/platform/image_sensor/camera_name
#./sys/devices/platform/mtk-msdc.0/mmc_host/mmc0/mmc0:0001/emmc_name
logfile=/mnt/obb/log.txt

GetInfo()
{
#开始处理版本号
	cktversion=`getprop internal.version`
	cktversion_project=${cktversion%%-*}
	ckt_tmp=${cktversion#*-}
	cktversion_softcode=${ckt_tmp%%_*}
	ckt_tmp=${ckt_tmp#*_}
	cktversion_customName=${ckt_tmp%%_*}
	ckt_tmp=${ckt_tmp#*_}
	cktversion_language=${ckt_tmp%%_*}
	ckt_tmp=${ckt_tmp#*_}
	cktversion_ver=${ckt_tmp%%_*}
	cktversion_longtime=${ckt_tmp#*_}	
	cktversion_shorttime=${cktversion_longtime:0:${#cktversion_longtime}-6}
	
#开始处理硬件信息	
	type="unknown" #硬件类型,根据这个hal/上层进行处理

	lcdname=`cat /sys/devices/platform/mtkfb.0/lcm_name`
	msensor=`cat /sys/bus/platform/drivers/msensor/chipinfo`
	gsensor=`cat /sys/bus/platform/drivers/gsensor/chipinfo`
	als_ps=`cat /sys/bus/platform/drivers/als_ps/chipinfo`
	gyroscope=`cat /sys/bus/platform/drivers/gyroscope/chipinfo`
	camera=`cat ./sys/devices/platform/image_sensor/camera_name`
	main_camera=${camera%%$'\n'*}
	sub_camera=${camera#*$'\n'}
	tv=`cat ./sys/bus/platform/drivers/MATV/atv_name`
	ctpinfo=`cat /sys/devices/platform/mtk-tpd/chipinfo`
	emmcinfo=`cat /sys/devices/platform/mtk-msdc.0/mmc_host/mmc0/mmc0:0001/emmc_name`
#结果应该类似如下	
##	cktversion=SLFQ-S0BB_CKT_L26EN_100_130806181309
##	lcdname=otm9608a_qhd_dsi_vdo
##	msensor=LSM303M Chip
##	gsensor=LSM303D Chip
##	als_ps=TMD2772 Chip
##	gyroscope=
##	main_camera=main: imx179mipiraw
##	sub_camera=sub:  t8ev3mipiraw

#需要调试的时候打开
	printf "cktversion=$cktversion\n" >>$logfile
	printf "cktversion_project=$cktversion_project\n" >>$logfile
	printf "cktversion_softcode=$cktversion_softcode\n" >>$logfile
	printf "cktversion_customName=$cktversion_customName\n" >>$logfile
	printf "cktversion_language=$cktversion_language\n" >>$logfile
	printf "cktversion_ver=$cktversion_ver\n" >>$logfile
	printf "cktversion_longtime=$cktversion_longtime\n" >>$logfile
	printf "cktversion_shorttime=$cktversion_shorttime\n" >>$logfile
	printf "lcdname=$lcdname\n"  >>$logfile
	printf "msensor=$msensor\n" >>$logfile
	printf "gsensor=$gsensor\n"  >>$logfile
	printf "als_ps=$als_ps\n" >>$logfile
	printf "gyroscope=$gyroscope\n"  >>$logfile
	printf "main_camera=$main_camera\n" >>$logfile
	printf "sub_camera=$sub_camera\n"  >>$logfile
	printf "tv=$tv\n" >>$logfile
	printf "ctpinfo=$ctpinfo\n" >>$logfile
	printf "emmcinfo=$emmcinfo\n" >>$logfile
}

#处理xs的相关信息,主要是根据slfq的硬件而到type和softcode和customName这几个值
handleforxs()
{
	if [ ! "$msensor" = "" ] && [ ! "$gsensor" = "" ] #有msensor和gsensor
	then
		type="a"

	elif [ ! "$gsensor" = "" ]
	then
		type="b"
	#else
	fi
}


handleforvegeta01a()
{
	if [ "$emmcinfo" = "THGBMAG7A2JBAIR-16G" ] #S0B 16GB+16Bb, S0C 8GB+8Gb
	then
		type="b"
		cktversion_softcode="S0B"
	elif [ ! "$gsensor" = "" ]
	then
		type="c"
		cktversion_softcode="S0C"
	#else
	fi
}


SetAllProp()
{
	setprop ro.ckt.type ${type}	
	setprop internal.version ${cktversion_project}-${cktversion_softcode}_${cktversion_customName}_${cktversion_language}_${cktversion_ver}_${cktversion_longtime}
	setprop ro.build.display.id  ${cktversion_project}-${cktversion_softcode}_${cktversion_customName}_${cktversion_language}_${cktversion_ver}_${cktversion_shorttime}
	setprop ro.mediatek.version.release ${cktversion_project}-${cktversion_softcode}_${cktversion_customName}_${cktversion_language}_${cktversion_ver}_${cktversion_shorttime}
#需要调试的时候打开
	printf "ro.ckt.type=${type}\n" >>$logfile
	printf "internal.version ${cktversion_project}-${cktversion_softcode}_${cktversion_customName}_${cktversion_language}_${cktversion_ver}_${cktversion_longtime}\n" >>$logfile
	printf "ro.build.display.id  ${cktversion_project}-${cktversion_softcode}_${cktversion_customName}_${cktversion_language}_${cktversion_ver}_${cktversion_shorttime}\n" >>$logfile
	printf "ro.mediatek.version.release ${cktversion_project}-${cktversion_softcode}_${cktversion_customName}_${cktversion_language}_${cktversion_ver}_${cktversion_shorttime}\n" >>$logfile
}

HandleTV() #如果没有tv,就删除tv相关的东西
{
	if [ "$tv" = "" ]
	then
		if [ -e /system/app/MATVEM.apk ] 
		then
			mount -o remount,rw /system
			mv /system/app/MATVEM.apk /system/app/MATVEM.bak
			mv /system/app/MtvPlayer.apk /system/app/MtvPlayer.bak
			mount -o remount,ro /system
			printf "del some tv apps\n" >>$logfile
		fi
	else
		if [ ! -e /system/app/MATVEM.apk ] 
		then
			mount -o remount,rw /system
			mv /system/app/MATVEM.bak /system/app/MATVEM.apk
			mv /system/app/MtvPlayer.bak /system/app/MtvPlayer.apk
			mount -o remount,ro /system
			printf "restore some tv apps\n" >>$logfile
		fi
	fi
}



UpdateCTP()
{
	printf "=========\n" >>$logfile
	#读取出来类似 ID:0xabcd VER:0x5501 IC:ektf2136 VENDOR:cs
	#             ID:0xa8 VER:0x10 IC:ft5336 VENDOR:ckt
	tmp=$ctpinfo
	ctpid=${tmp%% *}
	ctpid=${ctpid#*:}
	((ctpid=$ctpid))
		
	tmp=${tmp#* }

	ctpver=${tmp%% *}
	ctpver=${ctpver#*:}
	((ctpver=$ctpver))
		
	tmp=${tmp#* }
			
	ctpic=${tmp%% *}
	ctpic=${ctpic#*:}
	
	#得到ctp的类型,不同类型,读取版本号和升级工具不同	
	ctpType=${ctpic/#ektf*/ektf}
	ctpType=${ctpType/#ft*/ft}
		
	tmp=${tmp#* }
			
	ctpvendor=${tmp%% *}
	ctpvendor=${ctpvendor#*:}
	
		
	printf "ctpid=0x%x\n" $ctpid >>$logfile
	printf "ctpver=0x%x\n" $ctpver >>$logfile
	printf "ctpic=$ctpic\n" >>$logfile
	printf "ctpType=$ctpType\n" >>$logfile
	printf "ctpvendor=$ctpvendor\n" >>$logfile

	
	case $ctpType in
		"ft")
			handlectpforft
			;;
		"ektf")
			handlectpforektf
			;;
		*)
			;;
	esac
}



#升级ctp,这里用到了busybox!!!!
#升级策略
#如果在system/vendor/$ctpic/$ctpvendor/*.ekt,比如system/vendor/ektf2136/cs/*.ekt有n个相关文件
#通过路径保证id一样,也就是说如果你把别家的放到了这个目录,也会进行升级,升级只比较版本号
#比较版本号,版本号要求比目前机器中的高,也就是只可以升级,不可以降级
#找出其中多个ekt中,版本号最大的,用他进行升级
handlectpforektf()
{
	offsetforver=0x7d64
	
	bigestver=0;
	filename="";
	
	for i in system/vendor/$ctpic/$ctpvendor/*.*
	do
		if [ ! -e $i ]
		then
			printf "$i no exist\n">>$logfile;
			return;
		fi
		ver=`hexdump -s $offsetforver -n 2  -e '1/2 "0x%04x" "\n"' $i`
		((ver=$ver))
#		if [ "$ver" -gt "$ctpver" ] && [ "$ver" -gt "$bigestver" ]
		if [ "$ver" -ne "$ctpver" ]
		then
			bigestver=$ver; 
			filename=$i;
			break;
		fi
	done
	if [ ! "$filename" = "" ]
	then
		printf "handlectpforektf use $filename upgrade $ver=0x%x\n" $bigestver >>$logfile
		elan_iap $filename 0x15 2k >>$logfile
	else
		printf "handlectpforektf skip update ver=0x%x newver=0x%x\n" $ver $bigestver >>$logfile
	fi  
}

#升级ctp,这里用到了busybox!!!!
handlectpforft()
{
	offsetforver=0
	bigestver=0;
	filename="";
	
	for i in system/vendor/$ctpic/$ctpvendor/*.*
	do
		if [ ! -e $i ]
		then
			printf "$i no exist\n">>$logfile;
			return;
		fi
		offsetforver=`ls -l $i |awk '{print $4}'`
		offsetforver=$((offsetforver-2))
		ver=`hexdump -s $offsetforver -n 1  -e '1/2 "0x%02x" "\n"' $i`
		((ver=$ver))
#		if [ "$ver" -gt "$ctpver" ] && [ "$ver" -gt "$bigestver" ]
		if [ "$ver" -ne "$ctpver" ]
		then
			bigestver=$ver; 
			filename=$i;
			break;
		fi
	done
	if [ ! "$filename" = "" ]
	then
		printf "handlectpforft use $filename upgrade $ver=0x%x\n" $bigestver >>$logfile
		ft5606_upgrade $filename >>$logfile
	else
		printf "handlectpforft skip update ver=0x%x newver=0x%x\n" $ver $bigestver >>$logfile
	fi
}











#真正的处理流程
printf "======\n" >$logfile

#产生版本号之类的,不需要的话,注释它
GetInfo
HandleTV
case $cktversion_project in
	"XS")
		handleforxs
		;;
	"VEGETA01A")
		handleforvegeta01a
		;;
	*)
		;;
esac
SetAllProp	


#不需要ctp的自动升级,就把它给注释了,或者删除所有的etk
#
UpdateCTP






