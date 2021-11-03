package at.bestsolution.jfr.model

import at.bestsolution.jfr.jFRMeta.Clazz
import java.util.Map
import at.bestsolution.jfr.jFRMeta.Model

class Type extends TypeElement {

	new(String version, Clazz clazz, Map<String, Model> models) {
		super(version, clazz, models)
	}

}