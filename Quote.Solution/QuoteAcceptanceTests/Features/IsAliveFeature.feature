Feature: IsAliveFeature

This feature is about accessing isAlive page after running the service

@IsAlive
Scenario: Able to access isAlive page while the service is running
	Given the Quote Service Running
	When I check if it is alive
	Then it returns OK (http 200)
