#!/usr/bin/perl

# # #  REQUIRES PerlMagick (ImageMagick)

if($ARGV[0] eq '-help' || !@ARGV) {
	print 'CoroGIFer - HELP
Proper way of giving the arguments: srcImgName gifWitdh gifHeight framesCount delay gifName
Example 1 (correct): image.png 100 100 9 100 animation.gif
Example 2 (correct): source.png 50 75 20 50
Example 3 (incorrect) 
delay between frames is in centiseconds [cs]
gifName is optional';
	exit;
}

if($#ARGV + 1 < 4) {
	print 'Too few arguments! Proper way of giving the arguments: srcImgName gifWitdh gifHeight framesCount delay gifName
Use -help for more details';
	exit;
}

$srcImgName = $ARGV[0];  # Name of a source image with extension
$gifWitdh = $ARGV[1];  # Width of a GIF
$gifHeight = $ARGV[2];  # Height of a GIF
$framesCount = $ARGV[3];  # Number of frames to copy
$delay = $ARGV[4];  # Delay between frames in cs

if(!$ARGV[5]) {  # GIF Name is optional
	$gifName = 'new_gif.gif';  # Deafult name for generated GIF
} else {
	$gifName = $ARGV[5]; # with extension .gif
}

$frameSize = $gifWitdh.'x'.$gifHeight;

use Image::Magick;

$srcImage = Image::Magick->new;
$frame = Image::Magick->new(size=>$frameSize);
$gif = Image::Magick->new(size=>$frameSize);

$srcImage->Read($srcImgName); 
$frame->Read('canvas:black'); 

$srcImgWidth = $srcImage->Get('columns'); 
$srcImgHeight = $srcImage->Get('rows');

if ($gifWitdh <= $srcImgWidth && $gifHeight <= $srcImgHeight) {
	$cutFramesCount = 0; 
	
	# Calculating maximum frames number that can be cut from source image
	for ($iy = 0; $iy + $gifHeight <= $srcImgHeight && $cutFramesCount < $framesCount; $iy += $gifHeight) {
		for ($ix = 0; $ix + $gifWitdh <= $srcImgWidth && $cutFramesCount < $framesCount; $ix += $gifWitdh) {	
			$cutFramesCount++;
		}
	}
	
	if($cutFramesCount < $framesCount) {  # If there is too few frames to cut than requested (source image is too small or frames are too big)
		print "Maximum number of frames that is possible to cut from $srcImgName is $cutFramesCount!\n";
		exit;
	}
	
	$cutFramesCount = 0;
	
	# Generating GIF
	# Start from top left corner, move to the right.
	# When frame goes out of source image width, move down to the left side.
	# Finish when all frames are cut.
	for ($iy = 0; $iy + $gifHeight <= $srcImgHeight && $cutFramesCount < $framesCount; $iy += $gifHeight)
	{
		for ($ix = 0; $ix + $gifWitdh <= $srcImgWidth && $cutFramesCount < $framesCount; $ix += $gifWitdh)
		{	
			$cutFramesCount++;
				
			$frame->CopyPixels(image=>$srcImage, geometry=>$frameSize.'+'.$ix.'+'.$iy);
			
			$frame->Write('frame'.$cutFramesCount.'.png'); 
			$gif->Read('frame'.$cutFramesCount.'.png');
			
			`rm frame$cutFramesCount.png`;
		}
	}

	$gif->Set(delay=>$delay);

	$gif->Write($gifName);
	print "GIF has ben generated and saved as $gifName\n";
} else {
	print "Given frame size is bigger than a size of the source image!\n";
	exit;
}

undef $srcImage;
undef $frame;
undef $gif;