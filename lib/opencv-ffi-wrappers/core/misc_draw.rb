
require 'opencv-ffi-wrappers/core'
require 'opencv-ffi-wrappers/core/point'

module CVFFI

  def self.draw_circle( img, point, opts={} )
    color = opts[:color] || CVFFI::CvScalar.new( {:w=>255, :x=>255, :y=>255, :z=>0} )
    thickness = opts[:thickness] || 5
    radius = opts[:radius] || 1

    # A bit awkward.  cvCircle takes a CvArr* (either a CvMat or IplImage), 
    # so we want to "gently cast",
    # not force a conversion from CvMat -> IplImage or vice versa
    CVFFI::cvCircle( img.to_CvArr, point.to_CvPoint, radius, color.to_CvScalar, thickness,8,0 )
  end

  def self.draw_point( img, point, opts={} )
    opts[:thickness] = -1
    draw_circle( img, point, opts )
  end


  def self.draw_line( img, aPoint, bPoint, opts  = {} )
    color = opts[:color] || CVFFI::CvScalar.new( {:w=>255, :x=>255, :y=>255, :z=>0} )
    thickness = opts[:thickness] || 5

    CVFFI::cvLine( img.to_IplImage, aPoint.to_CvPoint, bPoint.to_CvPoint, color.to_CvScalar, thickness, 8, 0 )
  end

  def self.draw_homogeneous_line( img, line, opts = {} )
    ## TODO: This algorithm is ... not very good.  

    x = y = nil
    if (line[0]/line[1]).abs < 1.0
      x = [-1000,img.width + 1000]
      y = x.map { |x|
        -(line[0]*x + line[2])/line[1]
      }
    else
      y = [-1000,img.height+1000 ]
      x = y.map { |y|
        -(line[1]*y + line[2])/line[0]
      }
    end
    ep = [x,y].transpose

    CVFFI::draw_line( img, CVFFI::Point.new( *(ep[0]) ), CVFFI::Point.new( *(ep[1]) ), opts )
  end

  def self.put_text( img, text, point, opts = {} )
    color = opts[:color] || CVFFI::Scalar.new( 255,255,255,0 )
    thickness = opts[:thickness] || 2
    face = opts[:face] || opts[:typeface] || :CV_FONT_HERSHEY_SIMPLEX
    font = opts[:font] || nil
    hscale = opts[:hscale] || opts[:scale] || 1.0
    vscale = opts[:vscale] || opts[:scale] || hscale
    shear = opts[:shear] || 0.0

    unless font
      font = CVFFI::CvFont.new '\0'
      CVFFI::cvInitFont( font, face, hscale, vscale, shear, thickness, :CV_AA )
    end

    CVFFI::cvPutText( img.to_IplImage, text, point.to_CvPoint, font, color.to_CvScalar )
  end
end
