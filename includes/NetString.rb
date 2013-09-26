require "stringio"

module NetString
  LITTLE_ENDIAN = 1
  BIG_ENDIAN = 2
  
  SYS_ENDIAN = ([42].pack('i')[0].ord == 42) ? LITTLE_ENDIAN : BIG_ENDIAN
  
  def endian
    #@endian = SYS_ENDIAN if @endian.nil?
    @endian = BIG_ENDIAN if @endian.nil?
    @endian
  end
  
  def endianess=(endian)
    unless [BIG_ENDIAN, LITTLE_ENDIAN].include? endian
      raise 'Endianess should be set with const: NetString::LITTLE_ENDIAN or NetString::BIG_ENDIAN'
      exit
    end
    
    @endian = endian
  end
  
  def endianess data
    @endian = endian
    
    if @endian != SYS_ENDIAN
      data.reverse!
    end
  end
  
  def nsRead l, endian = true
    case self
    when String
      self.force_encoding 'ASCII-8BIT' if self.encoding.to_s == 'UTF-8'
      data = slice!(0, l)
    when File, StringIO
      data = read(l)
    end
    
    unless data.bytes.to_a.size == l
      self.log "self"
      pp l
      data.log "data"
    end
    
    raise 'NetString: incorrect length data read' unless data.bytes.to_a.size == l
    
    endianess(data) if endian
    data
  end
  
  def readByte; nsRead(1, false).unpack('c').first.to_i; end ## signed
  def readUByte; nsRead(1, false).unpack('C').first.to_i; end
  
  def readBoolean; !(readByte == 0); end
  
  def readShort; nsRead(2).unpack('s').first.to_i; end ## signed
  def readUShort; nsRead(2).unpack('S').first.to_i; end
  
  def readInt; nsRead(4).unpack('l').first.to_i; end ## signed
  def readUInt; nsRead(4).unpack('L').first.to_i; end
  
  def readDouble; nsRead(8, false).unpack('G').first.to_i; end ## Double-precision float
  def readFloat; puts '----------- CHECK ME READ FLOAT -----------'; nsRead(8).unpack('g').first.to_i; end ## Single-precision float
  
  def readQuad; nsRead(8).unpack('Q').first.to_i; end
  def readLongLong; a = readInt; b = readInt; a | (b << 32); end
  
  def readBytesAsString l; nsRead(l, false); end
  def readString; str = ''; while (char = readBytesAsString(1)) != "\x00"; str << char; end; str; end
  def readUTFString; s = readShort; readBytesAsString s; end
  
  alias_method :readUnsignedByte, :readUByte
  alias_method :readUnsignedShort, :readUShort
  alias_method :readUnsignedInt, :readUInt
  alias_method :readUTF, :readUTFString
  
  def nsWrite data, endian = true
    endianess(data) if endian
    
    case self.class.to_s
    when 'String'
      concat(data)
    when 'File'
      print data
    end
    
    self
  end
  
  def writeByte data; nsWrite([data].pack('c'), false); end
  def writeUByte data; nsWrite([data].pack('C'), false); end
  
  def writeBoolean data; nsWrite([data.to_i].pack('C'), false); end
  
  def writeShort data; nsWrite([data].pack('s')); end
  def writeUShort data; nsWrite([data].pack('S')); end
  
  def writeInt data; nsWrite([data].pack('l')); end
  def writeUInt data; nsWrite([data].pack('L')); end
  
  def writeDouble; puts '----------- CHECK ME WRITE DOUBLE -----------', nsWrite([data].pack('G')); end ## Double-precision float
  def writeFloat; puts '----------- CHECK ME WRITE FLOAT -----------', nsWrite([data].pack('g')); end ## Single-precision float
  
  def writeQuad data; nsWrite([data].pack('Q')); end
  
  def writeBytesAsString data; nsWrite(data, false); end
  def writeString data; nsWrite(data + "\x00", false); end
  def writeUTFString data; writeUShort(data.size); nsWrite(data, false); end
  
  def hexed(short = false)
    f = '%02X'
    j = ' '
    
    if short
      f = '%02x'
      j = ''
    end
    
    h = bytes.to_a.collect { |c| f % c }
    
    h.join j
  end
  
  def to_ansi
    string = ''
    
    t = bytes.to_a.each do |byte|
      byte = 46 if byte < 33 or byte > 126
      
      string += '  ' + byte.chr
    end
    
    string.strip
  end
  
  def log(name = nil, short = false)
    puts rlog(name, short)
  end
  
  def rlog(name, short = false)
    name = 'DATA DUMP' if name.nil?
    pad = '-' * 25
    
    firstline = "#{pad} #{name} (#{length}) #{pad}"
    endline = '-' * firstline.length 
    
    firstline << "\n" <<
      to_ansi << "\n" <<
      hexed(short) << "\n" <<
    endline
  end
  
  def to_block(l = 50, params = {})
    l /= 2
    
    self.strip!
    
    puts "#{'-' * l} #{self} #{'-' * l}\n"
    
    params.each { |k, v| puts "#{k}: #{v}" } if params.size
    yield
    
    puts "#{'-' * (2 * l + length + 2)}"
  end
end

class String
  include NetString
end

class IO
  include NetString
end

class StringIO
  include NetString
end