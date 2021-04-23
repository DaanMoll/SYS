classdef LegoCar < handle
    properties
        NormalSpeed;
        Speed;
        Turning;
        
        LeftMulti;
        RightMulti;
        
        myrobot;
        sonic;
        m_left;
        m_right;
        cs_left;
        cs_right;
    end
    
    
    properties(Constant)
        NormalMulti = 1;
        TurnMulti = 0.3;
        SharpTurnMulti = 0.1;
    end
    
    methods
        function obj = LegoCar(normalSpeed)
            obj.NormalSpeed = normalSpeed;
            obj.Speed = normalSpeed;
            obj.Turning = TurnDirection.Forward;
            
            obj.LeftMulti = 1;
            obj.RightMulti = 1;
            
            obj.myrobot = legoev3('usb');

            obj.m_left = motor(obj.myrobot, 'B');
            obj.m_right = motor(obj.myrobot, 'C');
            
            obj.sonic = sonicSensor(obj.myrobot, 2);

            obj.cs_left = colorSensor(obj.myrobot,1);
            obj.cs_right = colorSensor(obj.myrobot,4);
        end
        
        function SetSpeed(obj, speedColor)
            switch speedColor
                case 1
                    obj.Speed = obj.NormalSpeed / 2;
                    disp("slow");
                case 2
                    obj.Speed = obj.NormalSpeed * 1.5;
                    disp("fast");
                case 3
                    obj.Speed = obj.NormalSpeed;
                    disp("normal");
            end
            disp(obj.Speed);
        end
        
        function Start(obj)
            obj.m_left.start();
            obj.m_right.start();
        end
        
        function UpdateMotorSpeed(obj)
%             disp(obj.Speed);
%             disp(obj.LeftMulti);
%             disp(obj.Speed * obj.LeftMulti);
%             disp(obj.RightMulti);
%             disp(obj.Speed * obj.RightMulti);
            obj.m_left.Speed = obj.Speed * obj.LeftMulti;
            obj.m_right.Speed = obj.Speed * obj.RightMulti;
        end
        
        function TurnWheelsLeft(obj)
            obj.LeftMulti = -0.6 * obj.NormalMulti;
            obj.RightMulti = obj.NormalMulti;
        end
        
        function InplaceTurnWheelsLeft(obj)
            obj.LeftMulti = -obj.NormalMulti;
            obj.RightMulti = obj.NormalMulti;
        end
        
        function SharpTurnWheelsLeft(obj)
            obj.LeftMulti = -0.6 * obj.NormalMulti;
            obj.RightMulti =  obj.NormalMulti;
        end
        
        function TurnWheelsRight(obj)
            obj.LeftMulti = obj.NormalMulti;
            obj.RightMulti = -0.6 * obj.NormalMulti;
        end
        
        function InplaceTurnWheelsRight(obj)
            obj.LeftMulti = obj.NormalMulti;
            obj.RightMulti = -obj.NormalMulti;
        end
        
        function SharpTurnWheelsRight(obj)
            obj.LeftMulti = obj.NormalMulti;
            obj.RightMulti = -0.6 * obj.NormalMulti;
        end
        
        function TurnWheelsForward(obj)
            obj.LeftMulti = obj.NormalMulti;
            obj.RightMulti = obj.NormalMulti;
        end

        function StartSharpTurn(obj)
            if obj.Turning == TurnDirection.Left
                obj.SharpTurnWheelsLeft();
            end
            if obj.Turning == TurnDirection.Right
                obj.SharpTurnWheelsRight();
            end
        end
        
        function DriveUntilParking(obj)
            obj.Start();
            
            while true
                int_left = obj.cs_left.readLightIntensity('reflected');
                int_right = obj.cs_right.readLightIntensity('reflected');

                if CheckBothColorsLowerThenBlack(int_left, int_right)
                    obj.StartSharpTurn();
                end
                
                speed_color = GetSpeedColor(int_left, int_right);
                obj.SetSpeed(speed_color);
                disp(obj.Speed);
                obj.UpdateMotorSpeed();
                
                if obj.Turning == TurnDirection.Left
                    if CheckColorLowerThenBlack(int_left)
                        continue
                    end
                    obj.Turning = TurnDirection.Forward;
                    obj.TurnWheelsForward();
                end
                if obj.Turning == TurnDirection.Right
                    if CheckColorLowerThenBlack(int_right)
                        continue;
                    end
                    obj.Turning = TurnDirection.Forward;
                    obj.TurnWheelsForward();
                end
                if CheckColorLowerThenBlack(int_left)
                    obj.Turning = TurnDirection.Left;
                    obj.TurnWheelsLeft();
                    continue;
                elseif CheckColorLowerThenBlack(int_right)
                    obj.Turning = TurnDirection.Right;
                    obj.TurnWheelsRight();
                    continue;
                end
            end
        end
        
        function DriveUntilDoubleBlack(obj)
            obj.Start();
            
            while true
                int_left = obj.cs_left.readLightIntensity('reflected');
                int_right = obj.cs_right.readLightIntensity('reflected');

                if CheckBothColorsLowerThenBlack(int_left, int_right)
                    obj.Stop();
                    break;
                end
                
                speed_color = GetSpeedColor(int_left, int_right);
                obj.SetSpeed(speed_color);
                disp(obj.Speed);
                obj.UpdateMotorSpeed();
                
                if obj.Turning == TurnDirection.Left
                    if CheckColorLowerThenBlack(int_left)
                        continue
                    end
                    obj.Turning = TurnDirection.Forward;
                    obj.TurnWheelsForward();
                end
                if obj.Turning == TurnDirection.Right
                    if CheckColorLowerThenBlack(int_right)
                        continue;
                    end
                    obj.Turning = TurnDirection.Forward;
                    obj.TurnWheelsForward();
                end
                if CheckColorLowerThenBlack(int_left)
                    obj.Turning = TurnDirection.Left;
                    obj.TurnWheelsLeft();
                    continue;
                elseif CheckColorLowerThenBlack(int_right)
                    obj.Turning = TurnDirection.Right;
                    obj.TurnWheelsRight();
                    continue;
                end
            end
        end
        
        function DriveUntilParkingTurns(obj)
            obj.m_left.start();
            obj.m_right.start();
            
            while true
                int_left = obj.cs_left.readLightIntensity('reflected');
                int_right = obj.cs_right.readLightIntensity('reflected');

%                 if CheckBothColorsLowerThenBlack(int_left, int_right)
%                     obj.StartSharpTurn();
%                 end
                
                speed_color = GetSpeedColor(int_left, int_right);
                obj.SetSpeed(speed_color);
                disp(obj.Speed);
                obj.UpdateMotorSpeed();
                
                if obj.Turning == TurnDirection.Left
                    if CheckColorHigherThenBlack(int_right)
                        continue
                    end
                    obj.Turning = TurnDirection.Forward;
                    obj.TurnWheelsForward();
                end
                if obj.Turning == TurnDirection.Right
                    if CheckColorHigherThenBlack(int_left)
                        continue;
                    end
                    obj.Turning = TurnDirection.Forward;
                    obj.TurnWheelsForward();
                end
                if CheckColorLowerThenBlack(int_left)
                    obj.Turning = TurnDirection.Left;
                    obj.TurnWheelsLeft();
                    continue;
                elseif CheckColorLowerThenBlack(int_right)
                    obj.Turning = TurnDirection.Right;
                    obj.TurnWheelsRight();
                    continue;
                end
            end
        end
        
        function TurnToLeftLine(obj)
            obj.InplaceTurnWheelsLeft();
            obj.SetSpeed(1);
            obj.UpdateMotorSpeed();
            obj.Start();
            
            int_right = obj.cs_right.readLightIntensity('reflected');
            while CheckColorHigherThenBlack(int_right)
                int_right = obj.cs_right.readLightIntensity('reflected');
            end
            
            int_left = obj.cs_left.readLightIntensity('reflected');
            int_right = obj.cs_right.readLightIntensity('reflected');
            while CheckColorLowerThenBlack(int_right) || CheckColorLowerThenBlack(int_left)
                int_left = obj.cs_left.readLightIntensity('reflected');
                int_right = obj.cs_right.readLightIntensity('reflected');
            end
            
            int_right = obj.cs_right.readLightIntensity('reflected');
            while CheckColorHigherThenBlack(int_right)
                int_right = obj.cs_right.readLightIntensity('reflected');
            end
            
            obj.Stop();
        end
        
        function CheckParkDirection(obj)
            pause(3);
            
            obj.InplaceTurnWheelsLeft();
            obj.SetSpeed(1);
            obj.UpdateMotorSpeed();
            
            obj.Start();
            
            left_dist = 0;
            left_times = 0;
            
            int_left = obj.cs_left.readLightIntensity('reflected');
            int_right = obj.cs_right.readLightIntensity('reflected');
            while CheckColorLowerThenBlack(int_right) || CheckColorLowerThenBlack(int_left)
                left_dist = left_dist + obj.sonic.readDistance();
                left_times = left_times + 1;
                int_left = obj.cs_left.readLightIntensity('reflected');
                int_right = obj.cs_right.readLightIntensity('reflected');
            end
            
            int_right = obj.cs_right.readLightIntensity('reflected');
            while CheckColorHigherThenBlack(int_right)
                left_dist = left_dist + obj.sonic.readDistance();
                left_times = left_times + 1;
                int_right = obj.cs_right.readLightIntensity('reflected');
            end
            
            obj.Stop();
            pause(2);
            
            obj.InplaceTurnWheelsRight();
            obj.UpdateMotorSpeed();
            
            obj.Start();
            
            int_left = obj.cs_left.readLightIntensity('reflected');
            while CheckColorHigherThenBlack(int_left)
                int_left = obj.cs_left.readLightIntensity('reflected');
            end
            
            obj.Stop();
            pause(3);
            obj.Start();
            
            right_dist = 0;
            right_times = 0;
            
            int_left = obj.cs_left.readLightIntensity('reflected');
            int_right = obj.cs_right.readLightIntensity('reflected');
            while CheckColorLowerThenBlack(int_right) || CheckColorLowerThenBlack(int_left)
                right_dist = right_dist + obj.sonic.readDistance();
                right_times = right_times + 1;
                int_left = obj.cs_left.readLightIntensity('reflected');
                int_right = obj.cs_right.readLightIntensity('reflected');
            end
            
            int_left = obj.cs_left.readLightIntensity('reflected');
            while CheckColorHigherThenBlack(int_left)
                right_dist = right_dist + obj.sonic.readDistance();
                right_times = right_times + 1;
                int_left = obj.cs_left.readLightIntensity('reflected');
            end
            
            obj.Stop();
            
            if ((right_dist / right_times) > (left_dist / left_times))
                disp("right");
            else
                disp("left");
                obj.TurnToLeftLine();
            end
        end
        
        function Park(obj)
            obj.m_left.start();
            obj.m_right.start();
            
            obj.SetSpeed(3)
            obj.UpdateMotorSpeed();
            
            while true
                obj.UpdateMotorSpeed();
                int_left = obj.cs_left.readLightIntensity('reflected');
                int_right = obj.cs_right.readLightIntensity('reflected');

                if CheckBothColorsLowerThenBlack(int_left, int_right)
                    obj.Stop();
                    obj.CheckParkDirection();
                    obj.Turning = TurnDirection.Forward;
                    obj.DriveUntilDoubleBlack();
                    break;
                end
                
                if obj.Turning == TurnDirection.Left
                    if CheckColorHigherThenBlack(int_right)
                        continue
                    end
                    obj.Turning = TurnDirection.Forward;
                    obj.TurnWheelsForward();
                end
                if obj.Turning == TurnDirection.Right
                    if CheckColorHigherThenBlack(int_left)
                        continue;
                    end
                    obj.Turning = TurnDirection.Forward;
                    obj.TurnWheelsForward();
                end
                if CheckColorLowerThenBlack(int_left)
                    obj.Turning = TurnDirection.Left;
                    obj.TurnWheelsLeft();
                    continue;
                elseif CheckColorLowerThenBlack(int_right)
                    obj.Turning = TurnDirection.Right;
                    obj.TurnWheelsRight();
                    continue;
                end
            end
        end
        
        
        function Stop(obj)
            obj.m_left.stop();
            obj.m_right.stop();
        end
    end
end


function res = CheckColorLowerThenRed(intensity)
    res = intensity <= DefaultMaxIntensities.Red;
end

function res = CheckColorLowerThenGray(intensity)
    res = intensity <= DefaultMaxIntensities.Gray;
end

function res = CheckColorLowerThenBlack(intensity)
    res = intensity <= DefaultMaxIntensities.Black;
end
function res = CheckColorHigherThenBlack(intensity)
    res = intensity > DefaultMaxIntensities.Black;
end

function res = CheckBothColorsLowerThenBlack(intensity1, intensity2)
    res = CheckColorLowerThenBlack(intensity1) && CheckColorLowerThenBlack(intensity2);
end

function res = GetColor(intensity)
    if CheckColorLowerThenBlack(intensity)
        res = 0;
        return;
    end
    if CheckColorLowerThenGray(intensity)
        res = 1;
        return;
    end
    if CheckColorLowerThenRed(intensity)
        res = 2;
        return;
    end
    res = 3;   
end

function res = GetSpeedColor(intensity1, intensity2)
    color1 = GetColor(intensity1);
    color2 = GetColor(intensity2);
    if color1 ~= color2
        res = 0;
        return;
    end
    res = color1;
end
