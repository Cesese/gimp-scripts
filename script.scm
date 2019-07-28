(define (color-erase base
		    erase
		    output)
	(let* ((image (car (gimp-file-load RUN-NONINTERACTIVE base base)))
		 (drawable1 (car (gimp-image-get-active-drawable image))) ; background layer
		 (drawable2 (car (gimp-file-load-layer RUN-NONINTERACTIVE image erase)))) ; erase layer
		(gimp-image-insert-layer image drawable2 0 0) 
		(gimp-layer-add-alpha drawable2) ; alpha channel (layer)
		(gimp-layer-add-alpha drawable1) ; alpha channel (background)
		
; The following commented out stuff is what I used to take away the upper and lower bars of my layer picture. With gimp-image-select-contiguous-color I was using the magic wand, but then sometimes it didn't render well because the colors were too close to characters so instead I used gimp-image-select-rectangle which well, is the rectangle select tool.

;		(gimp-image-select-contiguous-color image CHANNEL-OP-ADD drawable2 1.0 1.0)
;		(gimp-image-select-contiguous-color image CHANNEL-OP-ADD drawable2 1.0 1279.0)

;		                                  add   x	y	w	h
;		(gimp-image-select-rectangle image 0	0	0	720	74)
;		(gimp-image-select-rectangle image 0	0	1093	720	187)

;		(gimp-drawable-edit-clear drawable2)

		(gimp-layer-set-mode drawable2 LAYER-MODE-COLOR-ERASE)
		(set! drawable1 (car (gimp-image-merge-visible-layers image CLIP-TO-BOTTOM-LAYER))) ; merging all layers
		(gimp-file-save RUN-NONINTERACTIVE image drawable1 output output)))

(define (layer-on-picture base
			 layer-pic
			 output)
	(let* ((image (car (gimp-file-load RUN-NONINTERACTIVE base base)))
		 (drawable1 (car (gimp-image-get-active-drawable image)))
		 (drawable2 (car (gimp-file-load-layer RUN-NONINTERACTIVE image layer-pic))))
		(gimp-image-insert-layer image drawable2 0 0)
		(set! drawable1 (car (gimp-image-merge-visible-layers image CLIP-TO-BOTTOM-LAYER)))
		(gimp-file-save RUN-NONINTERACTIVE image drawable1 output output)))


(define (batch-color-erase pattern1 ; base/*.png
			  pattern2 ; erase/*.png
			  pattern3) ; output/*.png
	(let* ((baselist (cadr (file-glob pattern1 1)))
		 (eraselist (cadr (file-glob pattern2 1)))
		 (outputlist (cadr (file-glob pattern3 1))))
		(while (not (null? baselist)) ; all the lists are the same length so it's alright. If not then the user is at fault (it won't break stuff anyway, just either end or produce some errors)
			 (let* ((base (car baselist))
				 (erase (car eraselist))
				 (output (car outputlist)))
				(color-erase base erase output)) ; calling my script
;			updating the lists
			 (set! baselist (cdr baselist))
			 (set! eraselist (cdr eraselist))
			 (set! outputlist (cdr outputlist)))))
									
(define (batch-layer-on-picture pattern1 ; base/*.png
			       template ; template.png
			       pattern2) ; output/*.png
	(let* ((baselist (cadr (file-glob pattern1 1)))
		 (outputlist (cadr (file-glob pattern2 1))))
		(while (not (null? baselist))
			 (let* ((base (car baselist))
				 (output (car outputlist)))
				(layer-on-picture base template output)) ; calling my script
;                       updating the lists
		         (set! baselist (cdr baselist))
			 (set! outputlist (cdr outputlist)))))
