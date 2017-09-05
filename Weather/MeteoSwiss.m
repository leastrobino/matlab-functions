%
%  MeteoSwiss.m
%
%  Created by Léa Strobino.
%  Copyright 2017 hepia. All rights reserved.
%

classdef MeteoSwiss < handle
  
  properties (Constant)
    server = 'http://www.meteoswiss.admin.ch';
  end
  
  properties (SetAccess = private)
    stations
  end
  
  properties (Access = private)
    version
  end
  
  methods
    
    function this = MeteoSwiss()
      [this.stations,this.version] = this.getStations();
    end
    
    function refresh(this)
      [this.stations,this.version] = this.getStations(0);
    end
    
    function o = getFoehn(this,station)
      if nargin > 1
        o = this.getMeasurement('foehn',station);
      else
        o = this.getMeasurementOverview('foehn');
      end
    end
    
    function o = getHumidity(this,station)
      if nargin > 1
        o = this.getMeasurement('humidity',station);
      else
        o = this.getMeasurementOverview('humidity');
      end
    end
    
    function o = getPrecipitation(this,station)
      if nargin > 1
        o = this.getMeasurement('precipitation',station);
      else
        o = this.getMeasurementOverview('precipitation');
      end
    end
    
    function o = getPressureQFE(this,station)
      if nargin > 1
        o = this.getMeasurement('pressure-qfe',station);
      else
        o = this.getMeasurementOverview('pressure-qfe');
      end
    end
    
    function o = getPressureQFF(this,station)
      if nargin > 1
        o = this.getMeasurement('pressure-qff',station);
      else
        o = this.getMeasurementOverview('pressure-qff');
      end
    end
    
    function o = getPressureQNH(this,station)
      if nargin > 1
        o = this.getMeasurement('pressure-qnh',station);
      else
        o = this.getMeasurementOverview('pressure-qnh');
      end
    end
    
    function o = getSnowNew(this,station)
      if nargin > 1
        o = this.getMeasurement('snow-new',station);
      else
        o = this.getMeasurementOverview('snow-new');
      end
    end
    
    function o = getSnowTotal(this,station)
      if nargin > 1
        o = this.getMeasurement('snow-total',station);
      else
        o = this.getMeasurementOverview('snow-total');
      end
    end
    
    function o = getSunshine(this,station)
      if nargin > 1
        o = this.getMeasurement('sunshine',station);
      else
        o = this.getMeasurementOverview('sunshine');
      end
    end
    
    function o = getTemperature(this,station)
      if nargin > 1
        o = this.getMeasurement('temperature',station);
      else
        o = this.getMeasurementOverview('temperature');
      end
    end
    
    function o = getWindDirection(this,station)
      if nargin > 1
        o = this.getMeasurement('wind-direction',station);
      else
        o = this.getMeasurementOverview('foehn');
      end
    end
    
    function o = getWindSpeed(this,station)
      if nargin > 1
        o = this.getMeasurement('wind-speed',station);
      else
        o = this.getMeasurementOverview('foehn');
      end
    end
    
  end
  
  methods (Access = private)
    
    function [s,v] = getStations(this,~)
      persistent stations version
      mlock();
      if isempty(stations) || nargin > 1
        s = this.urlread('/home/weather/measurement-values/measurement-values-at-meteorological-stations.html');
        s = regexp(s,'data-json-url="([^"]*)"','tokens');
        for i = 1:length(s)
          m = regexp(s{i}{1},'/([^/]*)/(version__[^/]*)/','tokens','once');
          version.(strrep(m{1},'-','_')) = m{2};
        end
        this.version = version;
        m = this.getJSON('temperature','overview');
        m = m.stations;
        for i = 1:length(m)
          station.name = m(i).city_name;
          station.coordinates = [m(i).coord_x m(i).coord_y];
          station.altitude = m(i).evelation;
          stations.(m(i).id) = station;
        end
        [~,i] = sort(fieldnames(stations));
        stations = orderfields(stations,i);
      end
      s = stations;
      v = version;
    end
    
    function o = getMeasurement(this,measurement,station)
      station = upper(station);
      if ~isfield(this.stations,station)
        error('MeteoSwiss:UnknownStation','Unknown station code.');
      end
      try
        m = this.getJSON(measurement,station);
      catch
        error('MeteoSwiss:NoData',...
          'No data for this station (%s => %s).',station,this.stations.(station).name);
      end
      o.legend = cell(1,length(m.series));
      o.unit = m.chart_options.value_suffix;
      o.xdata = zeros(length(m.series(1).data),1);
      o.ydata = zeros(length(m.series(1).data),length(m.series));
      for i = 1:length(m.series)
        o.legend{i} = m.series(i).name;
        for l = 1:length(m.series(i).data)
          if i == 1
            o.xdata(l) = m.series(i).data{l}(1);
          end
          if isempty(m.series(i).data{l}(2))
            o.ydata(l,i) = NaN;
          else
            o.ydata(l,i) = m.series(i).data{l}(2);
          end
        end
      end
      o.xdata = datetime(1E-3*o.xdata,'ConvertFrom','POSIXtime','Timezone','Europe/Zurich');
    end
    
    function o = getMeasurementOverview(this,measurement)
      m = this.getJSON(measurement,'overview');
      o.date = datetime(m.config.timestamp,'ConvertFrom','POSIXtime','Timezone','Europe/Zurich');
      o.unit = m.stations(1).value_suffix;
      for i = 1:length(m.stations)
        if isempty(m.stations(i).current_value)
          o.(m.stations(i).id) = NaN;
        else
          o.(m.stations(i).id) = m.stations(i).current_value;
        end
      end
      [~,i] = sort(fieldnames(o));
      o = orderfields(o,i);
    end
    
    function m = getJSON(this,measurement,file)
      measurement = [measurement '/' this.version.(strrep(measurement,'-','_'))];
      s = this.urlread(['/product/output/measured-values-v2/' measurement '/en/' file '.json']);
      m = json_decode(s);
    end
    
    function s = urlread(this,url)
      persistent isc
      if isempty(isc)
        isc = com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier();
      end
      url = java.net.URL([this.server url]);
      com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings();
      p = com.mathworks.webproxy.WebproxyFactory.findProxyForURL(url);
      if isempty(p)
        c = url.openConnection();
      else
        c = url.openConnection(p);
      end
      i = c.getInputStream();
      o = java.io.ByteArrayOutputStream();
      isc.copyStream(i,o);
      i.close();
      o.close();
      s = native2unicode(typecast(o.toByteArray()','uint8'),'UTF-8');
    end
    
  end
  
end
