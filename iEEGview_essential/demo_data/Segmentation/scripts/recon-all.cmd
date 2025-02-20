#--------------------------------------------
#@# MotionCor Sun Nov  6 02:30:51 EST 2016

 cp /usr/local/freesurfer/subjects/S2_Demo/mri/orig/001.mgz /usr/local/freesurfer/subjects/S2_Demo/mri/rawavg.mgz 


 mri_convert /usr/local/freesurfer/subjects/S2_Demo/mri/rawavg.mgz /usr/local/freesurfer/subjects/S2_Demo/mri/orig.mgz --conform 


 mri_add_xform_to_header -c /usr/local/freesurfer/subjects/S2_Demo/mri/transforms/talairach.xfm /usr/local/freesurfer/subjects/S2_Demo/mri/orig.mgz /usr/local/freesurfer/subjects/S2_Demo/mri/orig.mgz 

#--------------------------------------------
#@# Talairach Sun Nov  6 02:31:13 EST 2016

 mri_nu_correct.mni --n 1 --proto-iters 1000 --distance 50 --no-rescale --i orig.mgz --o orig_nu.mgz 


 talairach_avi --i orig_nu.mgz --xfm transforms/talairach.auto.xfm 


 cp transforms/talairach.auto.xfm transforms/talairach.xfm 

#--------------------------------------------
#@# Talairach Failure Detection Sun Nov  6 02:33:06 EST 2016

 talairach_afd -T 0.005 -xfm transforms/talairach.xfm 


 awk -f /usr/local/freesurfer/bin/extract_talairach_avi_QA.awk /usr/local/freesurfer/subjects/S2_Demo/mri/transforms/talairach_avi.log 


 tal_QC_AZS /usr/local/freesurfer/subjects/S2_Demo/mri/transforms/talairach_avi.log 

#--------------------------------------------
#@# Nu Intensity Correction Sun Nov  6 02:33:06 EST 2016

 mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --n 2 


 mri_add_xform_to_header -c /usr/local/freesurfer/subjects/S2_Demo/mri/transforms/talairach.xfm nu.mgz nu.mgz 

#--------------------------------------------
#@# Intensity Normalization Sun Nov  6 02:35:03 EST 2016

 mri_normalize -g 1 nu.mgz T1.mgz 

#--------------------------------------------
#@# Skull Stripping Sun Nov  6 02:37:58 EST 2016

 mri_em_register -skull nu.mgz /usr/local/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull.lta 


 mri_watershed -T1 -brain_atlas /usr/local/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull.lta T1.mgz brainmask.auto.mgz 


 cp brainmask.auto.mgz brainmask.mgz 

#-------------------------------------
#@# EM Registration Sun Nov  6 03:10:52 EST 2016

 mri_em_register -uns 3 -mask brainmask.mgz nu.mgz /usr/local/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.lta 

#--------------------------------------
#@# CA Normalize Sun Nov  6 03:40:10 EST 2016

 mri_ca_normalize -c ctrl_pts.mgz -mask brainmask.mgz nu.mgz /usr/local/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.lta norm.mgz 

#--------------------------------------
#@# CA Reg Sun Nov  6 03:42:08 EST 2016

 mri_ca_register -nobigventricles -T transforms/talairach.lta -align-after -mask brainmask.mgz norm.mgz /usr/local/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.m3z 

#--------------------------------------
#@# CA Reg Inv Mon Nov  7 02:11:14 EST 2016

 mri_ca_register -invert-and-save transforms/talairach.m3z 

#--------------------------------------
#@# Remove Neck Mon Nov  7 02:12:22 EST 2016

 mri_remove_neck -radius 25 nu.mgz transforms/talairach.m3z /usr/local/freesurfer/average/RB_all_2008-03-26.gca nu_noneck.mgz 

#--------------------------------------
#@# SkullLTA Mon Nov  7 02:14:30 EST 2016

 mri_em_register -skull -t transforms/talairach.lta nu_noneck.mgz /usr/local/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull_2.lta 

#--------------------------------------
#@# SubCort Seg Mon Nov  7 02:43:40 EST 2016

 mri_ca_label -align norm.mgz transforms/talairach.m3z /usr/local/freesurfer/average/RB_all_2008-03-26.gca aseg.auto_noCCseg.mgz 


 mri_cc -aseg aseg.auto_noCCseg.mgz -o aseg.auto.mgz -lta /usr/local/freesurfer/subjects/S2_Demo/mri/transforms/cc_up.lta S2_Demo 

#--------------------------------------
#@# Merge ASeg Mon Nov  7 03:22:37 EST 2016

 cp aseg.auto.mgz aseg.mgz 

#--------------------------------------------
#@# Intensity Normalization2 Mon Nov  7 03:22:37 EST 2016

 mri_normalize -aseg aseg.mgz -mask brainmask.mgz norm.mgz brain.mgz 

#--------------------------------------------
#@# Mask BFS Mon Nov  7 03:26:46 EST 2016

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# WM Segmentation Mon Nov  7 03:26:49 EST 2016

 mri_segment brain.mgz wm.seg.mgz 


 mri_edit_wm_with_aseg -keep-in wm.seg.mgz brain.mgz aseg.mgz wm.asegedit.mgz 


 mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz 

#--------------------------------------------
#@# Fill Mon Nov  7 03:29:37 EST 2016

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.auto_noCCseg.mgz wm.mgz filled.mgz 

#--------------------------------------------
#@# Tessellate lh Mon Nov  7 03:30:31 EST 2016

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Mon Nov  7 03:30:41 EST 2016

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Mon Nov  7 03:30:46 EST 2016

 mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Mon Nov  7 03:31:22 EST 2016

 mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology lh Mon Nov  7 03:35:50 EST 2016

 cp ../surf/lh.orig.nofix ../surf/lh.orig 


 cp ../surf/lh.inflated.nofix ../surf/lh.inflated 


 mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 S2_Demo lh 


 mris_euler_number ../surf/lh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm ../surf/lh.inflated 

#--------------------------------------------
#@# Make White Surf lh Mon Nov  7 04:29:47 EST 2016

 mris_make_surfaces -noaparc -whiteonly -mgz -T1 brain.finalsurfs S2_Demo lh 

#--------------------------------------------
#@# Smooth2 lh Mon Nov  7 04:36:05 EST 2016

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white ../surf/lh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Mon Nov  7 04:36:10 EST 2016

 mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/lh.inflated 


#-----------------------------------------
#@# Curvature Stats lh Mon Nov  7 04:38:38 EST 2016

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm S2_Demo lh curv sulc 

#--------------------------------------------
#@# Sphere lh Mon Nov  7 04:38:43 EST 2016

 mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Surf Reg lh Mon Nov  7 05:37:23 EST 2016

 mris_register -curv ../surf/lh.sphere /usr/local/freesurfer/average/lh.average.curvature.filled.buckner40.tif ../surf/lh.sphere.reg 

#--------------------------------------------
#@# Jacobian white lh Mon Nov  7 06:05:14 EST 2016

 mris_jacobian ../surf/lh.white ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Mon Nov  7 06:05:17 EST 2016

 mrisp_paint -a 5 /usr/local/freesurfer/average/lh.average.curvature.filled.buckner40.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Mon Nov  7 06:05:19 EST 2016

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 S2_Demo lh ../surf/lh.sphere.reg /usr/local/freesurfer/average/lh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ../label/lh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf lh Mon Nov  7 06:06:06 EST 2016

 mris_make_surfaces -white NOWRITE -mgz -T1 brain.finalsurfs S2_Demo lh 

#--------------------------------------------
#@# Surf Volume lh Mon Nov  7 06:19:12 EST 2016

 mris_calc -o lh.area.mid lh.area add lh.area.pial 


 mris_calc -o lh.area.mid lh.area.mid div 2 


 mris_calc -o lh.volume lh.area.mid mul lh.thickness 

#-----------------------------------------
#@# WM/GM Contrast lh Mon Nov  7 06:19:13 EST 2016

 pctsurfcon --s S2_Demo --lh-only 

#-----------------------------------------
#@# Parcellation Stats lh Mon Nov  7 06:19:28 EST 2016

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab S2_Demo lh white 

#-----------------------------------------
#@# Cortical Parc 2 lh Mon Nov  7 06:19:44 EST 2016

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 S2_Demo lh ../surf/lh.sphere.reg /usr/local/freesurfer/average/lh.destrieux.simple.2009-07-29.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 lh Mon Nov  7 06:20:41 EST 2016

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab S2_Demo lh white 

#-----------------------------------------
#@# Cortical Parc 3 lh Mon Nov  7 06:20:59 EST 2016

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 S2_Demo lh ../surf/lh.sphere.reg /usr/local/freesurfer/average/lh.DKTatlas40.gcs ../label/lh.aparc.DKTatlas40.annot 

#-----------------------------------------
#@# Parcellation Stats 3 lh Mon Nov  7 06:21:46 EST 2016

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas40.stats -b -a ../label/lh.aparc.DKTatlas40.annot -c ../label/aparc.annot.DKTatlas40.ctab S2_Demo lh white 

#--------------------------------------------
#@# Tessellate rh Mon Nov  7 06:22:02 EST 2016

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 rh Mon Nov  7 06:22:10 EST 2016

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 rh Mon Nov  7 06:22:15 EST 2016

 mris_inflate -no-save-sulc ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere rh Mon Nov  7 06:22:50 EST 2016

 mris_sphere -q -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology rh Mon Nov  7 06:27:17 EST 2016

 cp ../surf/rh.orig.nofix ../surf/rh.orig 


 cp ../surf/rh.inflated.nofix ../surf/rh.inflated 


 mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 S2_Demo rh 


 mris_euler_number ../surf/rh.orig 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm ../surf/rh.inflated 

#--------------------------------------------
#@# Make White Surf rh Mon Nov  7 07:32:17 EST 2016

 mris_make_surfaces -noaparc -whiteonly -mgz -T1 brain.finalsurfs S2_Demo rh 

#--------------------------------------------
#@# Smooth2 rh Mon Nov  7 07:38:44 EST 2016

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 rh Mon Nov  7 07:38:49 EST 2016

 mris_inflate ../surf/rh.smoothwm ../surf/rh.inflated 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/rh.inflated 


#-----------------------------------------
#@# Curvature Stats rh Mon Nov  7 07:41:18 EST 2016

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm S2_Demo rh curv sulc 

#--------------------------------------------
#@# Sphere rh Mon Nov  7 07:41:23 EST 2016

 mris_sphere -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#--------------------------------------------
#@# Surf Reg rh Mon Nov  7 08:33:25 EST 2016

 mris_register -curv ../surf/rh.sphere /usr/local/freesurfer/average/rh.average.curvature.filled.buckner40.tif ../surf/rh.sphere.reg 

#--------------------------------------------
#@# Jacobian white rh Mon Nov  7 09:05:36 EST 2016

 mris_jacobian ../surf/rh.white ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv rh Mon Nov  7 09:05:39 EST 2016

 mrisp_paint -a 5 /usr/local/freesurfer/average/rh.average.curvature.filled.buckner40.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc rh Mon Nov  7 09:05:41 EST 2016

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 S2_Demo rh ../surf/rh.sphere.reg /usr/local/freesurfer/average/rh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf rh Mon Nov  7 09:06:29 EST 2016

 mris_make_surfaces -white NOWRITE -mgz -T1 brain.finalsurfs S2_Demo rh 

#--------------------------------------------
#@# Surf Volume rh Mon Nov  7 09:19:11 EST 2016

 mris_calc -o rh.area.mid rh.area add rh.area.pial 


 mris_calc -o rh.area.mid rh.area.mid div 2 


 mris_calc -o rh.volume rh.area.mid mul rh.thickness 

#-----------------------------------------
#@# WM/GM Contrast rh Mon Nov  7 09:19:12 EST 2016

 pctsurfcon --s S2_Demo --rh-only 

#-----------------------------------------
#@# Parcellation Stats rh Mon Nov  7 09:19:32 EST 2016

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab S2_Demo rh white 

#-----------------------------------------
#@# Cortical Parc 2 rh Mon Nov  7 09:19:50 EST 2016

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 S2_Demo rh ../surf/rh.sphere.reg /usr/local/freesurfer/average/rh.destrieux.simple.2009-07-29.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 rh Mon Nov  7 09:20:57 EST 2016

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab S2_Demo rh white 

#-----------------------------------------
#@# Cortical Parc 3 rh Mon Nov  7 09:21:14 EST 2016

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 S2_Demo rh ../surf/rh.sphere.reg /usr/local/freesurfer/average/rh.DKTatlas40.gcs ../label/rh.aparc.DKTatlas40.annot 

#-----------------------------------------
#@# Parcellation Stats 3 rh Mon Nov  7 09:21:59 EST 2016

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas40.stats -b -a ../label/rh.aparc.DKTatlas40.annot -c ../label/aparc.annot.DKTatlas40.ctab S2_Demo rh white 

#--------------------------------------------
#@# Cortical ribbon mask Mon Nov  7 09:22:15 EST 2016

 mris_volmask --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon S2_Demo 

#--------------------------------------------
#@# ASeg Stats Mon Nov  7 09:42:55 EST 2016

 mri_segstats --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /usr/local/freesurfer/ASegStatsLUT.txt --subject S2_Demo 

#-----------------------------------------
#@# AParc-to-ASeg Mon Nov  7 09:46:19 EST 2016

 mri_aparc2aseg --s S2_Demo --volmask 


 mri_aparc2aseg --s S2_Demo --volmask --a2009s 

#-----------------------------------------
#@# WMParc Mon Nov  7 09:51:08 EST 2016

 mri_aparc2aseg --s S2_Demo --labelwm --hypo-as-wm --rip-unknown --volmask --o mri/wmparc.mgz --ctxseg aparc+aseg.mgz 


 mri_segstats --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject S2_Demo --surf-wm-vol --ctab /usr/local/freesurfer/WMParcStatsLUT.txt --etiv 

#--------------------------------------------
#@# BA Labels lh Mon Nov  7 10:01:44 EST 2016

 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA1.label --trgsubject S2_Demo --trglabel ./lh.BA1.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA2.label --trgsubject S2_Demo --trglabel ./lh.BA2.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA3a.label --trgsubject S2_Demo --trglabel ./lh.BA3a.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA3b.label --trgsubject S2_Demo --trglabel ./lh.BA3b.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA4a.label --trgsubject S2_Demo --trglabel ./lh.BA4a.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA4p.label --trgsubject S2_Demo --trglabel ./lh.BA4p.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA6.label --trgsubject S2_Demo --trglabel ./lh.BA6.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA44.label --trgsubject S2_Demo --trglabel ./lh.BA44.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA45.label --trgsubject S2_Demo --trglabel ./lh.BA45.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.V1.label --trgsubject S2_Demo --trglabel ./lh.V1.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.V2.label --trgsubject S2_Demo --trglabel ./lh.V2.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.MT.label --trgsubject S2_Demo --trglabel ./lh.MT.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.perirhinal.label --trgsubject S2_Demo --trglabel ./lh.perirhinal.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA1.thresh.label --trgsubject S2_Demo --trglabel ./lh.BA1.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA2.thresh.label --trgsubject S2_Demo --trglabel ./lh.BA2.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA3a.thresh.label --trgsubject S2_Demo --trglabel ./lh.BA3a.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA3b.thresh.label --trgsubject S2_Demo --trglabel ./lh.BA3b.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA4a.thresh.label --trgsubject S2_Demo --trglabel ./lh.BA4a.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA4p.thresh.label --trgsubject S2_Demo --trglabel ./lh.BA4p.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA6.thresh.label --trgsubject S2_Demo --trglabel ./lh.BA6.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA44.thresh.label --trgsubject S2_Demo --trglabel ./lh.BA44.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.BA45.thresh.label --trgsubject S2_Demo --trglabel ./lh.BA45.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.V1.thresh.label --trgsubject S2_Demo --trglabel ./lh.V1.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.V2.thresh.label --trgsubject S2_Demo --trglabel ./lh.V2.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/lh.MT.thresh.label --trgsubject S2_Demo --trglabel ./lh.MT.thresh.label --hemi lh --regmethod surface 


 mris_label2annot --s S2_Demo --hemi lh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l lh.BA1.label --l lh.BA2.label --l lh.BA3a.label --l lh.BA3b.label --l lh.BA4a.label --l lh.BA4p.label --l lh.BA6.label --l lh.BA44.label --l lh.BA45.label --l lh.V1.label --l lh.V2.label --l lh.MT.label --l lh.perirhinal.label --a BA --maxstatwinner --noverbose 


 mris_label2annot --s S2_Demo --hemi lh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l lh.BA1.thresh.label --l lh.BA2.thresh.label --l lh.BA3a.thresh.label --l lh.BA3b.thresh.label --l lh.BA4a.thresh.label --l lh.BA4p.thresh.label --l lh.BA6.thresh.label --l lh.BA44.thresh.label --l lh.BA45.thresh.label --l lh.V1.thresh.label --l lh.V2.thresh.label --l lh.MT.thresh.label --a BA.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -mgz -f ../stats/lh.BA.stats -b -a ./lh.BA.annot -c ./BA.ctab S2_Demo lh white 


 mris_anatomical_stats -mgz -f ../stats/lh.BA.thresh.stats -b -a ./lh.BA.thresh.annot -c ./BA.thresh.ctab S2_Demo lh white 

#--------------------------------------------
#@# BA Labels rh Mon Nov  7 10:05:49 EST 2016

 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA1.label --trgsubject S2_Demo --trglabel ./rh.BA1.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA2.label --trgsubject S2_Demo --trglabel ./rh.BA2.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA3a.label --trgsubject S2_Demo --trglabel ./rh.BA3a.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA3b.label --trgsubject S2_Demo --trglabel ./rh.BA3b.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA4a.label --trgsubject S2_Demo --trglabel ./rh.BA4a.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA4p.label --trgsubject S2_Demo --trglabel ./rh.BA4p.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA6.label --trgsubject S2_Demo --trglabel ./rh.BA6.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA44.label --trgsubject S2_Demo --trglabel ./rh.BA44.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA45.label --trgsubject S2_Demo --trglabel ./rh.BA45.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.V1.label --trgsubject S2_Demo --trglabel ./rh.V1.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.V2.label --trgsubject S2_Demo --trglabel ./rh.V2.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.MT.label --trgsubject S2_Demo --trglabel ./rh.MT.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.perirhinal.label --trgsubject S2_Demo --trglabel ./rh.perirhinal.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA1.thresh.label --trgsubject S2_Demo --trglabel ./rh.BA1.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA2.thresh.label --trgsubject S2_Demo --trglabel ./rh.BA2.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA3a.thresh.label --trgsubject S2_Demo --trglabel ./rh.BA3a.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA3b.thresh.label --trgsubject S2_Demo --trglabel ./rh.BA3b.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA4a.thresh.label --trgsubject S2_Demo --trglabel ./rh.BA4a.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA4p.thresh.label --trgsubject S2_Demo --trglabel ./rh.BA4p.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA6.thresh.label --trgsubject S2_Demo --trglabel ./rh.BA6.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA44.thresh.label --trgsubject S2_Demo --trglabel ./rh.BA44.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.BA45.thresh.label --trgsubject S2_Demo --trglabel ./rh.BA45.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.V1.thresh.label --trgsubject S2_Demo --trglabel ./rh.V1.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.V2.thresh.label --trgsubject S2_Demo --trglabel ./rh.V2.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /usr/local/freesurfer/subjects/fsaverage/label/rh.MT.thresh.label --trgsubject S2_Demo --trglabel ./rh.MT.thresh.label --hemi rh --regmethod surface 


 mris_label2annot --s S2_Demo --hemi rh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l rh.BA1.label --l rh.BA2.label --l rh.BA3a.label --l rh.BA3b.label --l rh.BA4a.label --l rh.BA4p.label --l rh.BA6.label --l rh.BA44.label --l rh.BA45.label --l rh.V1.label --l rh.V2.label --l rh.MT.label --l rh.perirhinal.label --a BA --maxstatwinner --noverbose 


 mris_label2annot --s S2_Demo --hemi rh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l rh.BA1.thresh.label --l rh.BA2.thresh.label --l rh.BA3a.thresh.label --l rh.BA3b.thresh.label --l rh.BA4a.thresh.label --l rh.BA4p.thresh.label --l rh.BA6.thresh.label --l rh.BA44.thresh.label --l rh.BA45.thresh.label --l rh.V1.thresh.label --l rh.V2.thresh.label --l rh.MT.thresh.label --a BA.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -mgz -f ../stats/rh.BA.stats -b -a ./rh.BA.annot -c ./BA.ctab S2_Demo rh white 


 mris_anatomical_stats -mgz -f ../stats/rh.BA.thresh.stats -b -a ./rh.BA.thresh.annot -c ./BA.thresh.ctab S2_Demo rh white 

#--------------------------------------------
#@# Ex-vivo Entorhinal Cortex Label lh Mon Nov  7 10:09:50 EST 2016

 mris_spherical_average -erode 1 -orig white -t 0.4 -o S2_Demo label lh.entorhinal lh sphere.reg lh.EC_average lh.entorhinal_exvivo.label 


 mris_anatomical_stats -mgz -f ../stats/lh.entorhinal_exvivo.stats -b -l ./lh.entorhinal_exvivo.label S2_Demo lh white 

#--------------------------------------------
#@# Ex-vivo Entorhinal Cortex Label rh Mon Nov  7 10:10:06 EST 2016

 mris_spherical_average -erode 1 -orig white -t 0.4 -o S2_Demo label rh.entorhinal rh sphere.reg rh.EC_average rh.entorhinal_exvivo.label 


 mris_anatomical_stats -mgz -f ../stats/rh.entorhinal_exvivo.stats -b -l ./rh.entorhinal_exvivo.label S2_Demo rh white 

