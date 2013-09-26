module MovingEntity
  attr_accessor :moving, :moveStartX, :moveStartY, :moveStartTime, :moveEndX, :moveEndY, :moveEndTime, :moveSpeed, :moveTime, :moveAngle, :moveDX, :moveDY
  
  def self.included(parent)
    @moving = false
    @moveStartX = 0
    @moveStartY = 0
    @moveStartTime = 0
    @moveEndX = 0
    @moveEndY = 0
    @moveEndTime = 0
    @moveSpeed = 0.1
    @moveTime = 0.0
    @moveAngle = 0
    @moveDX = 0
    @moveDY = 0
  end
  
  def update
    moveEnd if @moving && Time.now.to_f > @moveEndTime
  end
  
  def moving?
    @moving
  end
  
  def moveStart(moveEndX, moveEndY, moveSpeed)
    @moveStartX = @originX || moveEndX
    @moveStartY = @originY || moveEndY
    
    @moveStartTime = Time.now.to_f
    @moveEndX = moveEndX
    @moveEndY = moveEndY
    @moveSpeed = moveSpeed
    
    @moveTime = distanceManhattan(Point.new(@moveEndX, @moveEndY)) / @moveSpeed / 1000
    @moveEndTime = Time.now.to_f + @moveTime + 0.1 # 0.1s for ping/human-mind delay :)
    
    @moveAngle = Math.atan2(@moveEndY - @moveStartY, @moveEndX - @moveStartX)
    @moveDX = @moveSpeed * Math.cos(@moveAngle)
    @moveDY = @moveSpeed * Math.sin(@moveAngle)
    
    @moving = true
  end
  
  def moveEnd(moveEndX = nil, moveEndY = nil)
    @originX = moveEndX || @moveEndX || @originX
    @originY = moveEndY || @moveEndY || @originY
    
    @moving = false
  end
end