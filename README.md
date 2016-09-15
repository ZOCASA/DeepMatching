# DeepMatching

<p>Modified DeepMatching</p>

<p>Given a video and a reference image, applies DeepMatching to each frame of video w.r.t reference image. Also calculates a rudimentry score based on number of patches matched vs. no. of total patches. Creates two folder in the directory of video for video frames and for score.</p>

<p>
To run:<code>./helper_dm.sh path_to_reference_image path_to_video [options to DeepMatching]</code>
</p>

<p>Also made a simple python script to show images from a folder(upto 16) in a montage orderd by their score.</p>
