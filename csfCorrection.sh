#!/bin/bash

# CSF Correction

function csfCorrection {

		LOWER=$(echo "${CSF_Mean} - ${VoxelRange}" | bc -l);
 		UPPER=$(echo "${CSF_Mean} + ${VoxelRange}" | bc -l);
		
		# multiply Lesion mask by normalized T1 intensity
		 if $(fslmaths $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_${ANATOMICAL_ID}_int_scaled -mul $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_LesionMask${counter}_bin $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_Lesion${counter}_NormRange) ; then
		
			# remove CSF values from Lesion mask
			# get rid of anything above lower bound
			fslmaths $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_Lesion${counter}_NormRange -uthr $LOWER $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_CSFAdjusted_Lesion${counter}_lower;
		
			# get rid of anything below upper bound
			fslmaths $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_Lesion${counter}_NormRange -thr $UPPER $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_CSFAdjusted_Lesion${counter}_upper;
			
			# sum two together
			fslmaths $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_CSFAdjusted_Lesion${counter}_upper -add $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_CSFAdjusted_Lesion${counter}_lower $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_CSFAdjusted_Lesion${counter};
		
			# re-binarize Lesion mask
			fslmaths $SUBJECTOPDIR/Intermediate_Files/${SUBJ}_CSFAdjusted_Lesion${counter} -bin $SUBJECTOPDIR/${SUBJ}_CSFAdjusted_Lesion${counter}_bin;
	
			csfCorrLesionVol=$(fslstats $SUBJECTOPDIR/${SUBJ}_CSFAdjusted_Lesion${counter}_bin -V | awk '{print $2;}');
		
		else
		
			echo "
				Check Image Orientations for T1 and Lesion Mask. Skipping Subject: ${SUBJ}.";
			printf "${SUBJ} Skipped" >> "$WORKINGDIR"/lesion_data.csv;
			printf '\n' >> "$WORKINGDIR"/lesion_data.csv;
			cd "$INPUTDIR" || exit;
			continue;
			
		fi		
		
		echo ${csfCorrLesionVol};
}