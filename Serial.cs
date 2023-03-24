using Godot;
using System;
using System.IO.Ports;

public class Serial : Node
{
	public string data = "";
	private SerialPort port = new SerialPort("COM3", 9600);
	
	public override void _Ready()
	{
		//GD.Print("Opening port");
		port.ReadTimeout = 250;
	 	port.Open();
	}

	public override void _ExitTree()
	{
		port.Close();
	}
	
	 public override void _Process(float delta)
	{
			try {
				this.data = port.ReadLine();
			} catch (Exception) {
				return;
			}
	}
}
