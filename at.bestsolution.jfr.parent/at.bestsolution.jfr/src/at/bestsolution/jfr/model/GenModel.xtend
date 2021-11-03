package at.bestsolution.jfr.model

import java.util.List
import java.util.Map
import at.bestsolution.jfr.jFRMeta.Model

class GenModel {
	final String version
	final String distribution
	final Map<String, Model> models
	final List<Event> events;

	new(String version, String distribution, Map<String, Model> models) {
		this.version = version
		this.distribution = distribution
		this.models = models
		this.events = models.get(version).classes.filter[c|c.super == "jdk.jfr.Event"].map[c|new Event(version,c, models)].toList

	}

	def String getVersion() {
		return version
	}

	def String getDistribution() {
		return distribution
	}

	def List<Event> getEvents() {
		return events
	}
}
