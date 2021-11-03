package at.bestsolution.jfr.model

import java.util.Map
import at.bestsolution.jfr.jFRMeta.Clazz
import at.bestsolution.jfr.jFRMeta.Model

class TypeElement {
	final Clazz clazz
	final Map<String, Model> models
	final boolean isNew;

	new(String version, Clazz clazz, Map<String, Model> models) {
		this.models = models
		this.clazz = clazz
		this.isNew = models.keySet.indexed.findFirst[v|v.value == version].key > 0;
	}

	def isNew() {
		return isNew;
	}
}
